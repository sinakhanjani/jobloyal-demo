import "./RequestDetailBox.scss"
import React from "react";
import {Fab, Icon} from "@material-ui/core";
import {format} from "date-fns";
import {Link, useHistory} from "react-router-dom";

const RequestDetailBox = (props) => {
    const history = useHistory()
    return (<div className={'main-request-box'}>
            <div className="request-card">
                <div className="job-title">
                    Job Title <span>{props.data.job.title.en}</span>
                </div>
                <h3>Services</h3>
                <div className="services">
                    <table>
                        {
                            props.data.services.map((service) => {
                                return (<>
                                    <tr>
                                        <td className="title-row">{service.title}</td>
                                        <td className={service.accepted === true ? 'accepted' : ''}>{service.accepted === true ? 'Accepted' : 'Rejected'}</td>
                                        <td>{service.count} {service.unit_title}</td>
                                        <td>{service.price}</td>
                                    </tr>
                                    </>)
                            })
                        }
                    </table>
                </div>

                <h3 style={{marginTop: '33px'}}>Times Report</h3>
                <div className="times-report">
                    <table>
                        {
                            props.data.report.map(report => {
                                return (report && <tr>
                                    <td className="capitalize">{report.status}</td>
                                    <td>{new Date(report.created_at).toLocaleTimeString("en-US", {timeZone: "Europe/Zurich"})}</td>
                                </tr>)
                            })
                        }
                    </table>
                </div>

                {props.data.comment && <>
                    <h3 style={{marginTop: '33px'}}>Comment</h3>
                    <div className="times-report">
                        <b>{props.data.comment.rate} Star: </b>{props.data.comment.comment}
                    </div>
                </>}

            </div>

            <div className="information-box">
                <a href={`http://maps.google.com/maps?q=${props.data.latitude},${props.data.longitude}`}><Fab variant="extended" aria-label="Add">
                    <Icon className="mr-8">navigation</Icon>
                    Location
                </Fab>
                </a>
                <table>
                    <tr>
                        <td>Address</td>
                        <td>{props.data.address}</td>
                    </tr>
                    <tr>
                        <td>User</td>
                        <td className="capitalize"><Link to={`/dashboard/user/${props.data.user.id}`} >{props.data.user.name} {props.data.user.family}</Link></td>
                    </tr>
                    <tr>
                        <td>Jobber</td>
                        <td className="capitalize"><Link to={`/dashboard/jobber/${props.data.jobber.id}`} >{props.data.jobber.name} {props.data.jobber.family}</Link></td>
                    </tr>
                    <tr>
                        <td>Type</td>
                        <td>{props.data.time_base === true ? "Post Pay" : "Pre Pay"}</td>
                    </tr>
                    <tr>
                        <td>Total</td>
                        <td>{props.data.price}</td>
                    </tr>
                    <tr>
                        <td>Payable</td>
                        <td>{props.data.services.reduce((a, b) => {
                            return a + (b.accepted ? parseFloat(b.price) : 0)
                        }, 0)}</td>
                    </tr>
                    <tr>
                        <td>Paid</td>
                        <td>{props.data.paid === true ? "Yes" : "No"}</td>
                    </tr>
                    <tr>
                        <td>Deposited</td>
                        <td>{props.data.deposit_id === null ? "No" : "Yes"}</td>
                    </tr>
                    <tr>
                        <td>Created</td>
                        <td>{new Date(props.data.created_at).toLocaleString("en-US", {timeZone: "Europe/Zurich"})}</td>
                    </tr>
                    <tr>
                        <td>Arrival Time</td>
                        <td>{props.data.arrival_time}'</td>
                    </tr>

                </table>
            </div>
        </div>)
};

export default RequestDetailBox
