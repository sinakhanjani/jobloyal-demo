import React, {useEffect, useState} from "react";
import {Fab, Icon, Table, TableBody, TableCell, TableHead, TableRow} from "@material-ui/core";
import axios from "axios";
import {Breadcrumb, SimpleCard} from "matx";
import {Link} from "react-router-dom";
import SnackErrorVariant from "../common/SnackErrorVariant";
import ConfirmDialog from "../common/ConfirmDialog";
import UnitBaseDialog from "./UnitBaseDialog";


const fetchData = async (jobId) => {
    const response = await axios.post("/service/all", {job_id: jobId});
    return response.data.data;
};

const addServiceToJob = async (data) => {
    const response = await axios.post("/service/create", data);
    return response.data.data;
};

const deleteService = async (jobId) => {
    const response = await axios.post("/service/delete", {id: jobId});
    return response.data;
};
const fetchUnits = async () => {
    const response = await axios.get("/unit/all");
    return response.data;
};
const editTitleService = async (data) => {
    const response = await axios.post("/service/edit", data);
    return response.data;
};

const ServicesList = (props) => {
    const [data, setData] = useState({items: []});
    const [units, setUnits] = useState([]);
    const [openDialog, setOpenDialog] = useState(false);
    const [openEditDialog, setOpenEditDialog] = useState(false);
    const [openDelete, setOpenDelete] = useState(false);
    const [nodeToDelete, setNodeToDelete] = useState({});
    const [nodeToEdit, setNodeToEdit] = useState({});
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
        fetchUnits().then((units) => {
            if (units.data) {
                units.data.items.unshift({id: null,title: 'hour'});
                setUnits(units.data.items)
            }
        })
    }, []);

    function showAddServiceDialog () {
        setOpenDialog(true)
    }
    function handleCloseAddDialog() {
        setOpenDialog(false)
    }
    function showDeleteDialog() {
        setOpenDelete(true)
    }
    function handleCloseDelete() {
        setOpenDelete(false)
    }
    async function handleDelete() {
        const response = await deleteService(nodeToDelete.id);
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
        handleCloseDelete()

    }
    async function addService(title,unit) {
        const response = await addServiceToJob({job_id: props.id, title: title, unit_id: unit.id});
        response.unit = unit;
        data.items.push(response);
        setData(data);
        handleCloseAddDialog()
    }
    async function editService(title,unit) {
        const response = await editTitleService({id: nodeToEdit.id,title: title, unit_id: unit.id});
        response.unit = unit;
        const newItem = data.items;
        newItem.forEach((node) => {
            if (node.id === nodeToEdit.id) {
                node.title = title
                node.unit = unit
            }
        });
        data.items = newItem
        setData(data);
        setOpenEditDialog(false)
    }
    return (
        <>
            <Fab variant="extended" aria-label="Add" style={{float: 'right'}}
                 onClick={showAddServiceDialog}>
                <Icon className="mr-8">add</Icon>
                Add New Service
            </Fab>
            <div className="w-full overflow-auto">
                <Table className="whitespace-pre">
                    <TableHead>
                        <TableRow>
                            <TableCell className="px-0" style={{width: '6%'}}>Index</TableCell>
                            <TableCell className="px-0" style={{width: '12%'}}>Unit</TableCell>
                            <TableCell className="px-0">Title</TableCell>
                            <TableCell className="px-0" style={{width: '125px'}}>Action</TableCell>
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
                                                {subscriber.unit ? subscriber.unit.title : 'Hour'}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.title}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                <span style={{marginRight: '23px'}} >{subscriber.creator_user_id ?
                                                    <Link to={`/dashboard/user/${subscriber.creator_user_id}`}><Icon>person</Icon></Link> : <Icon>computer</Icon>}</span>
                                                <Icon style={{cursor: 'pointer', marginRight: '23px'}} onClick={() => {
                                                    setNodeToEdit(subscriber)
                                                    setOpenEditDialog(true)
                                                }}>edit</Icon>
                                                <Icon style={{cursor: 'pointer'}} onClick={() => {
                                                    setNodeToDelete({id: subscriber.id,title: subscriber.title})
                                                    showDeleteDialog()
                                                }}>delete</Icon>
                                            </TableCell>
                                        </TableRow>

                                    </>
                                ))}
                    </TableBody>
                </Table>

            </div>
            <UnitBaseDialog
                open={openDialog}
                handleClose={handleCloseAddDialog}
                units={units}
                okButtonPressed={async (title,unit) => {
                    await addService(title,unit)
                }}
            />
            <UnitBaseDialog
                open={openEditDialog}
                editing
                handleClose={() => {setOpenEditDialog(false)}}
                units={units}
                node={nodeToEdit}
                okButtonPressed={async (title,unit) => {
                    await editService(title,unit)
                }}
            />
            <ConfirmDialog
                open={openDelete}
                handleClose={() => {setOpenDelete(false)}}
                titleDialog={`Delete ${nodeToDelete.title}`}
                contentDialog="services deleted when it have not any used by jobbers, even one jobber used it you can not delete it"
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
                        {name: "Services"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="Services">

                <ServicesList id={props.match.params.id}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
