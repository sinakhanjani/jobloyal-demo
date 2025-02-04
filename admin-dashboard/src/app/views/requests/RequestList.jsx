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


const fetchData = async (pagination) => {
    const response = await axios.post("/request/all", pagination);
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
            axios.post("/request/search", {page: page, limit: rowsPerPage, s: search.text}).then(result => {
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
            <Input
                style={{marginBottom: '10px', padding: '10px 0'}}
                placeholder="Search Here..."
                inputProps={{'aria-label': 'description'}}
                onChange={(e) => {
                    setSearch({text: e.target.value})
                }}
                value={search.text}
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
                        <TableCell className="px-0">Job Title</TableCell>
                        <TableCell className="px-0">User</TableCell>
                        <TableCell className="px-0">Jobber</TableCell>
                        <TableCell className="px-0">Status</TableCell>
                        <TableCell className="px-0">Price</TableCell>
                        <TableCell className="px-0">Type</TableCell>
                        <TableCell className="px-0">Address</TableCell>
                        <TableCell className="px-0">Created Date</TableCell>
                    </TableRow>
                </TableHead>
                <TableBody>
                    {
                        data.hasOwnProperty("items") &&
                        data.items
                            .map((subscriber, index) => (
                                <>
                                    <TableRow key={index} style={{display: 'content'}}>
                                        <TableCell className="px-0 capitalize" align="left">
                                            <Link to={`/dashboard/request/${subscriber.id}`}
                                                  style={{display: "content"}}>
                                                {subscriber.job_title.en}
                                            </Link>
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            <Link to={`/dashboard/user/${subscriber.user_id}`}
                                                  style={{display: "content"}}>
                                                {subscriber.user_name}
                                            </Link>
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            <Link to={`/dashboard/jobber/${subscriber.jobber_id}`}
                                                  style={{display: "content"}}>
                                            {subscriber.jobber_name}
                                            </Link>
                                        </TableCell>
                                        <TableCell className="px-0 capitalize" align="left">
                                            {subscriber.status}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {subscriber.price}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {subscriber.time_base === true ? "Post Payment" : "Pre Payment"}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {subscriber.address}
                                        </TableCell>
                                        <TableCell className="px-0 capitalize">
                                            {new Date(subscriber.created_at).toLocaleString("en-US", {timeZone: "Europe/Zurich"})}
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
                        {name: "Requests"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="Requests">
                <UsersList search={search}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
