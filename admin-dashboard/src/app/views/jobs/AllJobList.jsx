import React, {useEffect, useState} from "react";
import {
    IconButton,
    Table,
    TableHead,
    TableBody,
    TableRow,
    TableCell,
    Icon,
    TablePagination
} from "@material-ui/core";
import axios from "axios";
import { Breadcrumb, SimpleCard } from "matx";
import {TextValidator} from "react-material-ui-form-validator";
import {useSelector} from "react-redux";
import {Link} from "react-router-dom";
import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";
import Snackbar from "@material-ui/core/Snackbar";
import SnackbarContent from "@material-ui/core/SnackbarContent";
import {amber} from "@material-ui/core/colors";
import CloseIcon from "@material-ui/icons/Close";
import AddTwoLanguageDialog from "../common/AddTwoLanguageDialog";
import EditTwoLanguageDialog from "../common/EditTwoLanguageDialog";
import ConfirmDialog from "../common/ConfirmDialog";
import SnackErrorVariant from "../common/SnackErrorVariant";


const fetchData = async (pagination) => {
    const response = await axios.post("/job/anything",pagination);
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

const List = () => {
    const [data, setData] = useState({});
    const rowsPerPage = 20;
    const [page, setPage] = React.useState(0);
    const [count, setCount] = React.useState(0);
    const [nodeToDelete, setNodeToDelete] = useState({});
    const [openDelete, setOpenDelete] = useState(false);
    const [openSnackError, setOpenSnackError] = React.useState(false);
    const [showEditDialog, setShowEditDialog] = useState(false);
    const [nodeToEdit, setNodeToEdit] = useState({title: {en: '',fr: ''}});


    useEffect(() => {
        fetchData({page: page, limit: rowsPerPage}).then((data) => {
            setData(data);
            if (page === 0) {
                setCount(data.count)
            }
        });

    },[page]);


    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };
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

    const handleChangeRowsPerPage = event => {
    };
    return (<>
        <div className="w-full overflow-auto">
            <Table className="whitespace-pre">
                <TableHead>
                    <TableRow>
                        <TableCell className="px-0" style={{width: '6%'}}>Index</TableCell>
                        <TableCell className="px-0" style={{width: '12%'}}>EN Title</TableCell>
                        <TableCell className="px-0">FR Title</TableCell>
                        <TableCell className="px-0" style={{width: '120px'}}>Action</TableCell>
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

            <TablePagination
                className="px-4"
                rowsPerPageOptions={[rowsPerPage]}
                component="div"
                count={count || 0}
                rowsPerPage={rowsPerPage}
                page={page}
                backIconButtonProps={{
                    "aria-label": "Previous Page"
                }}
                nextIconButtonProps={{
                    "aria-label": "Next Page"
                }}
                onChangePage={handleChangePage}
            />
        </div>
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

const AppTable = () => {
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        { name: "Jobloyal", path: "/" },
                        { name: "Jobs" }
                    ]}
                />
            </div>
            <div className="py-3" />
            <SimpleCard title="All Jobs">
                <List />
            </SimpleCard>
        </div>
    );
};

export default AppTable;
