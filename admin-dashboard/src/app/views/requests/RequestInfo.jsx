import React, {useEffect, useState} from "react";
import SimpleCard from "../../../matx/components/cards/SimpleCard";
import Breadcrumb from "../../../matx/components/Breadcrumb";
import axios from "axios";
import {Grid, Icon} from "@material-ui/core";
import {Link} from "react-router-dom";
import RequestDetailBox from "./RequestDetailBox";

const fetchData = async (id) => {
    const response = await axios.post('/request/get/',{id:id});
    return response.data.data
};

const RequestDetail = (props) => {
    const [detail,setDetail] = useState({});
    useEffect(() => {
        fetchData(props.id).then(response => {
            if (response) {
                setDetail(response)
            }
        })
    },[]);
    return detail.hasOwnProperty("id") &&
            (<>
                <RequestDetailBox data={detail} />
            </>)
};

const RequestInfo = (props) => {
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        { name: "Jobloyal", path: "/" },
                        { name: "Requests", path:"/requests" },
                        { name: "Detail" }
                    ]}
                />
            </div>
            <div className="py-3" />
             <RequestDetail id={props.match.params.id}/>
        </div>
    )
};

export default RequestInfo
