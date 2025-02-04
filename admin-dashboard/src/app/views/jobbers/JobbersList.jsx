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
import Input from "@material-ui/core/Input";
import InputAdornment from "@material-ui/core/InputAdornment";
import {Search} from "@material-ui/icons";


const fetchData = async (pagination) => {
    const response = await axios.post("/jobbers",pagination);
    return response.data.data;
};

const UsersList = () => {
    const [users, setUsers] = useState({});
    const rowsPerPage = 20;
    const [page, setPage] = React.useState(0);
    const [count, setCount] = React.useState(0);
    const [isSearching, setSearching] = React.useState(false);
    let [search, setSearch] = React.useState({text: ''});

    useEffect(() => {
        if (search.hasOwnProperty("text") && search.text.length > 1) {
            if (isSearching === false) {
                setPage(0);
            }
            axios.post("/jobbers/search",{page: page, limit: rowsPerPage,s: search.text}).then(result => {
                setUsers(result.data.data);
                if (page === 0) {
                    setCount(result.data.data.count)
                }
            });
            setSearching(true);
        }
        else {
            if (isSearching === true) {
                setPage(0)
            }
            fetchData({page: page, limit: rowsPerPage}).then((data) => {
                setUsers(data);
                if (page === 0) {
                    setCount(data.count)
                }
            });
            setSearching(false);
        }
    },[search,page]);


    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = event => {
    };
    return (
        <div className="w-full overflow-auto">
            <Input
                style={{marginBottom: '10px', padding: '10px 0'}}
                placeholder="Search Here..."
                inputProps={{ 'aria-label': 'description' }}
                onChange={(e) => {setSearch({text: e.target.value})}}
                fullWidth
                startAdornment={
                    <InputAdornment position="start">
                        <Search style={{color: "rgb(196, 196, 196)"}}/>
                    </InputAdornment>
                }
            />

            <Table className="whitespace-pre">
                <TableHead>
                    <TableRow>
                        <TableCell className="px-0">Name</TableCell>
                        <TableCell className="px-0">Family</TableCell>
                        <TableCell className="px-0">Id</TableCell>
                        <TableCell className="px-0">Phone</TableCell>
                        <TableCell className="px-0">Region</TableCell>
                        <TableCell className="px-0">Activation</TableCell>
                        <TableCell className="px-0">Authorized</TableCell>
                        <TableCell className="px-0">Register Date</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {
                        users.hasOwnProperty("items") &&
                        users.items
                            .map((subscriber, index) => (
                                <>
                                    <TableRow key={index} style={{display: 'content'}}>
                                        <TableCell className="px-0 capitalize" align="left">
                                            <Link to={`/dashboard/jobber/${subscriber.id}`} style={{display: "content"}}>
                                                {subscriber.name}
                                            </Link>
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            {subscriber.family}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            {subscriber.identifier}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            {subscriber.phone_number}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {subscriber.region}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {
                                                ((subscriber.finite !== null && subscriber.finite === true && subscriber.expired != null && subscriber.expired < new Date()) || subscriber.finite === null) ?
                                                    <Icon color="primary">check</Icon> :
                                                    <Icon color="error">close</Icon>
                                            }
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {
                                                (subscriber.authorized) ?
                                                    <Icon color="primary">check</Icon> :
                                                    <Icon color="error">close</Icon>
                                            }
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {new Date(subscriber.created_at).toLocaleDateString("en-US", {timeZone: "Europe/Zurich"})}
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
    );
};

const AppTable = () => {
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        { name: "Jobloyal", path: "/" },
                        { name: "Jobbers" }
                    ]}
                />
            </div>
            <div className="py-3" />
            <SimpleCard title="Jobbers">
                <UsersList />
            </SimpleCard>
        </div>
    );
};

export default AppTable;
