import React, {useEffect, useState} from "react";
import {Fab, Icon, Table, TableBody, TableCell, TableHead, TableRow} from "@material-ui/core";
import axios from "axios";
import {Breadcrumb, SimpleCard} from "matx";
import {Link} from "react-router-dom";
import SnackErrorVariant from "../common/SnackErrorVariant";
import ConfirmDialog from "../common/ConfirmDialog";
import OneLanguageDialog from "./OneLanguageDialog";

const createUnit = async (data) => {
    const response = await axios.post("/unit/create", data);
    return response.data;
};
const deleteUnit = async (id) => {
    const response = await axios.post("/unit/delete", {id: id});
    return response.data;
};
const fetchUnits = async () => {
    const response = await axios.get("/unit/all");
    return response.data;
};
const editTitleUnit = async (data) => {
    const response = await axios.post("/unit/edit", data);
    return response.data;
};

const ServicesList = (props) => {
    const [units, setUnits] = useState([]);
    const [openDialog, setOpenDialog] = useState(false);
    const [openEditDialog, setOpenEditDialog] = useState(false);
    const [openDelete, setOpenDelete] = useState(false);
    const [nodeToDelete, setNodeToDelete] = useState({});
    const [nodeToEdit, setNodeToEdit] = useState({});
    const [openSnackError, setOpenSnackError] = React.useState(false);


    useEffect(() => {
        fetchUnits().then((units) => {
            if (units.data && units.data.items) {
                setUnits(units.data.items)
            }
            else {
                setOpenSnackError(true)
            }
        })
    }, []);

    function showAddDialog () {
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
        const response = await deleteUnit(nodeToDelete.id);
        if (response.success === true) {
            const newItems = units.filter((e) => {
                return e.id !== nodeToDelete.id
            });
            setUnits(newItems)
        }
        else {
            setOpenSnackError(true)
        }
        handleCloseDelete()

    }
    async function addUnit(title) {
        const response = await createUnit({title: title});
        if (response.data) {
            units.push(response.data);
            setUnits(units);
        }
        handleCloseAddDialog()
    }
    async function editUnit(title) {
        const response = await editTitleUnit({id: nodeToEdit.id,title: title});
        const newItem = units;
        units.forEach((node) => {
            if (node.id === nodeToEdit.id) {
                node.title = title
            }
        });
        setUnits(newItem);
        setOpenEditDialog(false)
    }
    return (
        <>
            <Fab variant="extended" aria-label="Add" style={{float: 'right'}}
                 onClick={showAddDialog}>
                <Icon className="mr-8">add</Icon>
                Add New Unit
            </Fab>
            <div className="w-full overflow-auto">
                <Table className="whitespace-pre">
                    <TableHead>
                        <TableRow>
                            <TableCell className="px-0" style={{width: '6%'}}>Index</TableCell>
                            <TableCell className="px-0" >Unit</TableCell>
                            <TableCell className="px-0" style={{width: '75px'}}>Action</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {
                            units && units.length > 0 &&
                            units
                                .map((subscriber, index) => (
                                    <>
                                        <TableRow key={index} style={{display: 'content'}}>
                                            <TableCell className="px-0 capitalize" align="left">
                                                {index + 1}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.title}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                <Icon style={{cursor: 'pointer'}} onClick={() => {
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
            <OneLanguageDialog
                open={openDialog}
                handleClose={handleCloseAddDialog}
                okButtonPressed={async (title) => {
                    await addUnit(title)
                }}
            />
            <OneLanguageDialog
                open={openEditDialog}
                editing
                handleClose={() => {setOpenEditDialog(false)}}
                node={nodeToEdit}
                okButtonPressed={async (title) => {
                    await editUnit(title)
                }}
            />
            <ConfirmDialog
                open={openDelete}
                handleClose={() => {setOpenDelete(false)}}
                titleDialog={`Delete ${nodeToDelete.title}`}
                contentDialog="Unit deleted when it have not any used by jobbers, even if one jobber used it, you can not delete it"
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
                        {name: "Units"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="Units">

                <ServicesList id={props.match.params.id}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
