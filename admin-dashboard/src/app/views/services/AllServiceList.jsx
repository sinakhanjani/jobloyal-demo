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
import UnitBaseDialog from "./UnitBaseDialog";
import ConfirmDialog from "../common/ConfirmDialog";
import SnackErrorVariant from "../common/SnackErrorVariant";


const fetchData = async (pagination) => {
    const response = await axios.post("/service/anything",pagination);
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

const List = () => {
    const [data, setData] = useState({});
    const [units, setUnits] = useState([]);
    const [openEditDialog, setOpenEditDialog] = useState(false);
    const [nodeToEdit, setNodeToEdit] = useState({});
    const rowsPerPage = 20;
    const [page, setPage] = React.useState(0);
    const [count, setCount] = React.useState(0);
    const [nodeToDelete, setNodeToDelete] = useState({});
    const [openDelete, setOpenDelete] = useState(false);
    const [openSnackError, setOpenSnackError] = React.useState(false);

    useEffect(() => {
        fetchData({page: page, limit: rowsPerPage}).then((data) => {
            setData(data);
            if (page === 0) {
                setCount(data.count)
            }
        });
        fetchUnits().then((units) => {
            if (units.data) {
                units.data.items.unshift({id: null,title: 'hour'});
                setUnits(units.data.items)
            }
        })

    },[page]);


    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };
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
    function handleCloseSnack() {
        setOpenSnackError(false)
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
    return (<>
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
                                                <span style={{marginRight: '23px'}} >{subscriber.creator_user_id ? <Link to={`/dashboard/user/${subscriber.creator_user_id}`}><Icon>person</Icon></Link> : <Icon>computer</Icon>}</span>
                                                <Icon style={{cursor: 'pointer',marginRight: '23px'}} onClick={() => {
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

const AppTable = () => {
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        { name: "Jobloyal", path: "/" },
                        { name: "Services" }
                    ]}
                />
            </div>
            <div className="py-3" />
            <SimpleCard title="All Services">
                <List />
            </SimpleCard>
        </div>
    );
};

export default AppTable;
