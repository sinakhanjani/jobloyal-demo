import React, {useEffect, useState} from "react";
import {Fab, Icon, Table, TableBody, TableCell, TableHead, TableRow} from "@material-ui/core";
import axios from "axios";
import {Breadcrumb, SimpleCard} from "matx";
import SnackErrorVariant from "../common/SnackErrorVariant";
import ConfirmDialog from "../common/ConfirmDialog";
import AddVersionDialog from "./AddVersionDialog";

const createVersion = async (data) => {
    const response = await axios.post("/version/add", data);
    return response.data;
};
const deleteVersion = async (id) => {
    const response = await axios.post("/version/delete", {id: id});
    return response.data;
};
const fetchVersions = async () => {
    const response = await axios.get("/version/all");
    return response.data;
};

const ServicesList = (props) => {
    const [versions, setVersions] = useState([]);
    const [openDialog, setOpenDialog] = useState(false);
    const [openDelete, setOpenDelete] = useState(false);
    const [nodeToDelete, setNodeToDelete] = useState({});
    const [openSnackError, setOpenSnackError] = React.useState(false);

    useEffect(() => {
        fetchVersions().then((versions) => {
            if (versions.data && versions.data.items) {
                setVersions(versions.data.items)
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
        const response = await deleteVersion(nodeToDelete.id);
        if (response.success === true) {
            const newItems = versions.filter((e) => {
                return e.id !== nodeToDelete.id
            });
            setVersions(newItems)
        }
        else {
            setOpenSnackError(true)
        }
        handleCloseDelete()

    }
    async function addVersion(data) {
        const response = await createVersion(data);
        if (response.success === true) {
            versions.unshift(response.data);
            setVersions(versions);
        }
        handleCloseAddDialog()
    }
    return (
        <>
            <Fab variant="extended" aria-label="Add" style={{float: 'right'}}
                 onClick={showAddDialog}>
                <Icon className="mr-8">add</Icon>
                Add New Version
            </Fab>
            <div className="w-full overflow-auto">
                <Table className="whitespace-pre">
                    <TableHead>
                        <TableRow>
                            <TableCell className="px-0" style={{width: '6%'}}>Id</TableCell>
                            <TableCell className="px-0" >Device</TableCell>
                            <TableCell className="px-0" >App</TableCell>
                            <TableCell className="px-0" >Force</TableCell>
                            <TableCell className="px-0" >Version</TableCell>
                            <TableCell className="px-0" >Link</TableCell>
                            <TableCell className="px-0">Created Date</TableCell>
                            <TableCell className="px-0">Action</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {
                            versions && versions.length > 0 &&
                            versions
                                .map((subscriber, index) => (
                                    <>
                                        <TableRow key={index} style={{display: 'content'}}>
                                            <TableCell className="px-0 capitalize" align="left">
                                                {subscriber.id}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.device_type}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.is_jobber_app === true ? "Jobber" : "User"}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.force === true ? "Yes" : "No"}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.version_code}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {<a href={subscriber.link}>Link</a> }
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {new Date(subscriber.createdAt).toLocaleDateString("en-US", {timeZone: "Europe/Zurich"})}
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                <Icon style={{cursor: 'pointer'}} onClick={() => {
                                                    setNodeToDelete({id: subscriber.id, title: subscriber.device_type + " " + " " + (subscriber.is_jobber_app ? "Jobber" : "User") + " v" + subscriber.version_code})
                                                    showDeleteDialog()
                                                }}>delete</Icon>
                                            </TableCell>
                                        </TableRow>

                                    </>
                                ))}
                    </TableBody>
                </Table>

            </div>
            <AddVersionDialog
                open={openDialog}
                handleClose={handleCloseAddDialog}
                okButtonPressed={async (data) => {
                    await addVersion(data)
                }}
            />
            <ConfirmDialog
                open={openDelete}
                handleClose={() => {setOpenDelete(false)}}
                titleDialog={`Delete ${nodeToDelete.title}`}
                contentDialog="if you delete the version, all previous accessible version work fine and not any alert displayed to users"
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
                        {name: "Versions"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="Versions">

                <ServicesList id={props.match.params.id}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
