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
import {Link} from "react-router-dom";
import SnackErrorVariant from "../common/SnackErrorVariant";
import InputAdornment from "@material-ui/core/InputAdornment";
import {Search} from "@material-ui/icons";
import Input from "@material-ui/core/Input";


const fetchData = async (pagination) => {
    const response = await axios.get("/jobber/auth/all");
    return response.data.data;
};
const acceptRequest = async (jobberId) => {
    const response = await axios.post("/jobber/auth/verify", {jobber_id: jobberId});
    return response.data;
};
const rejectRequest = async (jobberId) => {
    const response = await axios.post("/jobber/auth/reject", {jobber_id: jobberId});
    return response.data;
};

const List = (props) => {
    const [data, setData] = useState({});
    const rowsPerPage = 20;
    const [page, setPage] = React.useState(0);
    const [count, setCount] = React.useState(0);
    const [openSnackError, setOpenSnackError] = React.useState(false);
    const [reload, setReload] = React.useState(0);
    const [isSearching, setSearching] = React.useState(false);
    let [search, setSearch] = React.useState({text: ''});


    let lock = false;
    if (props.search)
        lock = true;
    useEffect(() => {
        if (props.search)
            setSearch({text: props.search});
    }, []);

    useEffect(() => {
        if (search.hasOwnProperty("text") && search.text.length > 1) {
            if (isSearching === false) {
                setPage(0);
            }
            setSearching(true);
            axios.post("/jobber/auth/search", {page: page, limit: rowsPerPage, s: search.text}).then(result => {
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
                    setData(data);
                    if (page === 0) {
                        setCount(data.count)
                    }
                });
            }
            lock = false
        }
    }, [page, reload,search]);


    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const verifyReceipt = (id) => {
        acceptRequest(id).then(res => {
            if (res.success === true) {
                setReload(id)
            }
        })
    };
    const rejectReceipt = (id) => {
        rejectRequest(id).then(res => {
            if (res.success === true) {
                setReload(id)
            }
        })
    };

    return (<>
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
                            <TableCell className="px-0" style={{width: '6%'}}>Index</TableCell>
                            <TableCell className="px-0" style={{width: '12%'}}>Jobber</TableCell>
                            <TableCell className="px-0">File</TableCell>
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
                                                <Link to={`/dashboard/jobber/${subscriber.jobber_id}`}>
                                                    {subscriber.name}
                                                </Link>
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                <a href={subscriber.doc_url}
                                                   target="_blank"><IconButton><Icon>crop_original</Icon></IconButton></a>
                                            </TableCell>
                                            <TableCell className="px-0 capitalize">
                                                {subscriber.accepted === null &&
                                                    <>
                                                    <IconButton
                                                        onClick={async () => {
                                                            await verifyReceipt(subscriber.jobber_id)
                                                        }}><Icon>done_all</Icon></IconButton>
                                                    < IconButton
                                                    onClick={async () => {
                                                    await rejectReceipt(subscriber.jobber_id)
                                                }}><Icon>close</Icon></IconButton></>
                                                }
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
            <SnackErrorVariant
                open={openSnackError}
                handleClose={() => {
                    setOpenSnackError(false)
                }}
            />
        </>
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
                        {name: "Documents"}
                    ]}
                />
            </div>
            <div className="py-3"/>
            <SimpleCard title="All New Sent Document">
                <List search={search}/>
            </SimpleCard>
        </div>
    );
};

export default AppTable;
