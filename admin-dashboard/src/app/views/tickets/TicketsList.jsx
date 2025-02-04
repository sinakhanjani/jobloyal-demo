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
import {Breadcrumb, SimpleCard} from "matx";
import {TextValidator} from "react-material-ui-form-validator";
import {useSelector} from "react-redux";
import {Link} from "react-router-dom";
import Input from "@material-ui/core/Input";
import InputAdornment from "@material-ui/core/InputAdornment";
import {Search} from "@material-ui/icons";
import "./Tickets.scss"

const fetchData = async (pagination) => {
    const response = await axios.post("/messages", pagination);
    return response.data.data;
};

const UsersList = (props) => {
    const [data, setData] = useState({});
    const rowsPerPage = 20;
    const [page, setPage] = React.useState(0);
    const [count, setCount] = React.useState(0);
    const [isSearching, setSearching] = React.useState(false);
    let [search, setSearch] = React.useState({text: ''});
    let lock = false;
    if (props.search)
        lock = true;
    useEffect(() => {
        if (props.search)
            setSearch({text: props.search});
    }, []);

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    useEffect(() => {
        if (search.hasOwnProperty("text") && search.text.length > 1) {
            if (isSearching === false) {
                setPage(0);
            }
            setSearching(true);
            axios.post("/support/search", {page: page, limit: rowsPerPage, s: search.text}).then(result => {
                setData(result.data.data);
                if (page === 0) {
                    setCount(result.data.data.count)
                }
            });
        } else {
            if (!lock) {
                if (isSearching === true) {
                    setPage(0)
                }
                setSearching(false);
                fetchData({page: page, limit: rowsPerPage}).then((data) => {
                    if (isSearching === false) {
                        setData(data);
                        if (page === 0) {
                            setCount(data.count)
                        }
                    }
                });
            }
            lock = false
        }
    }, [search, page]);


    const handleChangeRowsPerPage = event => {
    };
    return (
        <div className="w-full overflow-auto">
            <Table className="whitespace-pre">
                <TableHead>
                    <TableRow>
                        <TableCell className="px-0">User</TableCell>
                        <TableCell className="px-0">Subject</TableCell>
                        <TableCell className="px-0">State</TableCell>
                        <TableCell className="px-0">Created Date</TableCell>
                        <TableCell className="px-0">Action</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {
                        data.hasOwnProperty("items") &&
                        data.items
                            .map((subscriber, index) => (
                                <>
                                    <TableRow key={index} style={{display: 'content'}} className={`${subscriber.reply ? "replied" : "pending"}`}>
                                        <TableCell className="px-0 capitalize" align="left">
                                            <Link to={`/dashboard/${subscriber.user.is_jobber ? "jobber" : "user"}/${subscriber.user.id}`}
                                                  style={{display: "content"}}>
                                                {subscriber.user.name} {subscriber.user.family}
                                            </Link>
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            {subscriber.subject}
                                        </TableCell>
                                        <TableCell className={`px-0 capitalize`} align="left">
                                            {subscriber.reply ? "replied" : "pending"}
                                        </TableCell>

                                        <TableCell className="px-0 capitalize" align="left">
                                            {new Date(subscriber.createdAt).toLocaleString("en-US", {timeZone: "Europe/Zurich"})}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            <Link to={`/dashboard/ticket/reply/${subscriber.id}`}>
                                                <Icon>reply</Icon>
                                            </Link>
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

const AppTable = (props) => {

    const search = props.match.params.s;
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        {name: "Jobloyal", path: "/"},
                        {name: "Tickets"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="Tickets">
                <UsersList search={search}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
