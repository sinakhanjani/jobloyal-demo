import React, {useEffect, useState} from "react";
import SimpleCard from "../../../matx/components/cards/SimpleCard";
import Breadcrumb from "../../../matx/components/Breadcrumb";
import axios from "axios";
import {Grid, Icon} from "@material-ui/core";
import {Link} from "react-router-dom";

const fetchUserData = async (id) => {
    const response = await axios.get('/user/' + id);
    return response.data.data
};
const UserDetail = (props) => {
    const [detail,setDetail] = useState({});
    useEffect(() => {
        fetchUserData(props.id).then(r => {
            if (r) {
                setDetail(r)
            }
        })
    },[]);
    return (<>
        {detail.hasOwnProperty("id") &&
        (<>
                <Grid container spacing={3}  style={{marginBottom: '40px'}}>
                    <Grid item key="first">
                        <div
                            className={`h-132 w-132 border-radius-8 elevation-z6 justify-center items-center`}
                        >
                            <span style={{textAlign: 'center',marginTop: '40px',fontWeight: 100,display: 'block'}}>Total Request</span>
                            <span style={{textAlign: 'center',fontSize: '27px',fontWeight: 800,display: 'block'}}>{detail.total_request}</span>
                        </div>
                    </Grid>
                    <Grid item key="second">
                        <div
                            className={`h-132 w-132 border-radius-8 elevation-z6 justify-center items-center`}
                        >
                            <span style={{textAlign: 'center',marginTop: '40px',fontWeight: 100,display: 'block'}}>Done Request</span>
                            <span style={{textAlign: 'center',fontSize: '27px',fontWeight: 800,display: 'block'}}>{detail.done_request}</span>
                        </div>
                    </Grid>
                    <Grid item key="three">
                        <div
                            className={`h-132 w-132 border-radius-8 elevation-z6 justify-center items-center`}
                        >
                            <span style={{textAlign: 'center',marginTop: '40px',fontWeight: 100,display: 'block'}}>Unfinished</span>
                            <span style={{textAlign: 'center',fontSize: '27px',fontWeight: 800,display: 'block'}}>{detail.total_request - detail.done_request}</span>
                        </div>
                    </Grid>

                    <Grid item key="four">
                        <div
                            className={`h-132 w-132 border-radius-8 elevation-z6 justify-center items-center`}
                        >
                            <span style={{textAlign: 'center',marginTop: '40px',fontWeight: 100,display: 'block'}}>Status</span>
                            <span style={{textAlign: 'center',display: 'block'}}>{detail.is_user_suspended === 1 ? <Icon  fontSize='large'>close</Icon> : <Icon fontSize='large' >check</Icon>}</span>
                        </div>
                    </Grid>
                </Grid>

                <p><b>Name:</b> {detail.name}</p>
                <p><b>Family:</b> { detail.family}</p>
                <p><b>Phone Number:</b> {detail.phone_number}</p>
                <p><b>Gender:</b> {detail.gender === true ? 'Man' : 'Woman'}</p>
                <p><b>BirthDay:</b> {new Date(detail.birthday).toLocaleString("en-US", {timeZone: "Europe/Zurich"})}</p>
                <p><b>Email:</b> {detail.email}</p>
                <p><b>Address:</b> {detail.address}</p>
                <p><b>Created Account At:</b> {new Date(detail.created_at).toLocaleString("en-US", {timeZone: "Europe/Zurich"})}</p>
                <br />
                <br />
                <h3>Last Request Detail</h3>
                <p>{detail.name + " " + detail.family} created an request at {new Date(detail.request.created_at).toLocaleString("en-US", {timeZone: "Europe/Zurich"})} on <a target="_blank" href={`http://maps.google.com/maps?q=${detail.request.lat},${detail.request.long}`}>(this location)</a> and you can see detail of Request <Link to={"/dashboard/request/" + detail.request.id}>here</Link></p>

            </>
        )}
        </>
      )
};

const UserInfo = (props) => {
    console.log(props.match.params.id);
    return (
        <div className="m-sm-30">
            <div className="mb-sm-30">
                <Breadcrumb
                    routeSegments={[
                        { name: "Jobloyal", path: "/" },
                        { name: "Users", path:"/users" },
                        { name: "Detail" }
                    ]}
                />
            </div>
            <div className="py-3" />

            <SimpleCard title="User Detail">
                <UserDetail id={props.match.params.id}/>
            </SimpleCard>
        </div>
    )
};

export default UserInfo
