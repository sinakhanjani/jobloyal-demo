import React, {useEffect, useState} from "react";
import {Fab, Icon, Table, TableBody, TableCell, TableHead, TableRow} from "@material-ui/core";
import axios from "axios";
import {Breadcrumb, SimpleCard} from "matx";
import {Link} from "react-router-dom";
import AddTwoLanguageDialog from "../common/AddTwoLanguageDialog";
import SnackErrorVariant from "../common/SnackErrorVariant";
import ConfirmDialog from "../common/ConfirmDialog";
import EditTwoLanguageDialog from "../common/EditTwoLanguageDialog";


const fetchData = async (categoryId) => {
    const response = await axios.post("/job/all", {category_id: categoryId});
    return response.data.data;
};

const addJobToCategory = async (data) => {
    const response = await axios.post("/job/create", data);
    return response.data.data;
};

const deleteJob = async (jobId) => {
    const response = await axios.post("/job/delete", {job_id: jobId});
    return response.data;
};

const editTitleOfJob = async (data) => {
    const response = await axios.post("/job/edit", data);
    return response.data;
};

const JobsList = (props) => {
    const [data, setData] = useState({items: []});
    const [openAddDialog, setOpenAddDialog] = useState(false);
    const [openDelete, setOpenDelete] = useState(false);
    const [nodeToDelete, setNodeToDelete] = useState({});
    const [showEditDialog, setShowEditDialog] = useState(false);
    const [nodeToEdit, setNodeToEdit] = useState({title: {en: '',fr: ''}});
    const [page, setPage] = React.useState(0);
    const [count, setCount] = React.useState(0);
    const [openSnackError, setOpenSnackError] = React.useState(false);

    useEffect(() => {
        fetchData(props.id).then((data) => {
            if (data) {
                setData(data);
                if (page === 0) {
                    setCount(data.count)
                }
            }
        });
    }, []);

    async function handleDelete() {
       const response = await deleteJob(nodeToDelete.id);
       if (response.success === true) {
           const newItems = data.items;
           data.items = newItems.filter((e) => {
               return e.id !== nodeToDelete.id
           });
           setData(data)
       }
       else {
           setOpenSnackError(true)
       }
       setOpenDelete(false)
    }
    async function addJob(fr,en) {
        const response = await addJobToCategory({category_id: props.id, title_fr: fr, title_en: en});
        data.items.push(response);
        setData(data);
        setOpenAddDialog(false)
    }

    async function editJob(fr,en) {
        const response = await editTitleOfJob({title_en: en, title_fr: fr,id: nodeToEdit.id});
        if (response.success === true) {
            const newItems = data.items;
            newItems.forEach((e) => {
                if (e.id === nodeToEdit.id) {
                    e.title = {fr: response.data.title_fr, en: response.data.title_en}
                }
            });
            data.items = newItems;
            setData(data);
            setShowEditDialog(false)
        }
    }

    return (
        <>
            <Fab variant="extended" aria-label="Add" style={{float: 'right'}}
            onClick={() => {setOpenAddDialog(true)}}>
                <Icon className="mr-8">add</Icon>
                Add New Job
            </Fab>
            <div className="w-full overflow-auto">
                <Table className="whitespace-pre">
                    <TableHead>
                        <TableRow>
                            <TableCell className="px-0" style={{width: '6%'}}>Index</TableCell>
                            <TableCell className="px-0" style={{width: '12%'}}>EN Title</TableCell>
                            <TableCell className="px-0">FR Title</TableCell>
                            <TableCell className="px-0" style={{width: '130px'}}>Action</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {
                            data && data.hasOwnProperty("items") &&
                            data.items
                                .map((subscriber, index) => (
                                    <>
                                        <TableRow key={index} style={{display: 'content'}}>
                                            <TableCell className="px-0 capitalize" align="left">
                                                {index + 1}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.title.en}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.title.fr}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                <Link to={`/dashboard/services/${subscriber.id}`}>
                                                    <Icon style={{cursor: 'pointer',marginRight: '20px'}}>widgets</Icon>
                                                </Link>
                                                <Icon style={{cursor: 'pointer',marginRight: '20px'}} onClick={() => {
                                                    setNodeToEdit({id: subscriber.id,title: subscriber.title});
                                                    setShowEditDialog(true)
                                                }}>edit</Icon>
                                                <Icon style={{cursor: 'pointer'}} onClick={() => {
                                                    setNodeToDelete({id: subscriber.id,title: subscriber.title.en})
                                                    setOpenDelete(true)
                                                }}>delete</Icon>

                                            </TableCell>
                                        </TableRow>

                                    </>
                                ))}
                    </TableBody>
                </Table>

            </div>

            <AddTwoLanguageDialog
                open={openAddDialog}
                handleClose={() => {setOpenAddDialog(false)}}
                onAddBtnPressed={async ({en, fr}) => {
                    await addJob(fr, en)
                }}
                dialogTitle="Add New Job"
                dialogContentText="Adding a new job to this category, please sure that this job is related to this category because user should able to find job from categories."
            />
            <EditTwoLanguageDialog
                open={showEditDialog}
                handleClose={() => {setShowEditDialog(false)}}
                onEditBtnPressed={async ({en, fr}) => {
                    await editJob(fr, en)
                }}
                oldTitle={nodeToEdit.title}
                dialogTitle={`Edit ${nodeToEdit.title.en}`}
                dialogContentText="Editing the title of job can confuse all jobber and user, please be careful in this operation"
            />
            <ConfirmDialog
                open={openDelete}
                handleClose={() => {setOpenDelete(false)}}
                titleDialog={`Delete ${nodeToDelete.title}`}
                contentDialog="jobs deleted when it have not any used by jobbers, even one jobber used it you can not delete it"
                onOKPressed={async () => {
                    await handleDelete()
                }}
            />
            <SnackErrorVariant
                open={openSnackError}
                handleClose={() => {setOpenSnackError(false)}}
            />
        </>
    );
};

const AppTable = (props) => {
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        {name: "Jobloyal", path: "/"},
                        {name: "Jobs"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="Jobs">

                <JobsList id={props.match.params.id}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
