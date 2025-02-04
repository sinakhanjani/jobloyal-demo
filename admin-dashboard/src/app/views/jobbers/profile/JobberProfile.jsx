import React, {useEffect, useState} from "react";
import axios from "axios";
import "../../categories/treeview.scss"
import "./Profile.scss"
import Rating from "@material-ui/lab/Rating";
import Star from '@material-ui/icons/Star';
import Icon from "@material-ui/core/Icon";
import FormControl from "@material-ui/core/FormControl";
import Select from "@material-ui/core/Select";
import MenuItem from "@material-ui/core/MenuItem";
import Tags from "../../common/Tags";
import CircularProgress from "@material-ui/core/CircularProgress";
import ConfirmDialog from "../../common/ConfirmDialog";
import SnackErrorVariant from "../../common/SnackErrorVariant";
import {Link, Redirect} from "react-router-dom";

const fetchUserData = async (id) => {
    const response = await axios.get('/jobber/' + id);
    return response.data.data
};


const ItemClickableList = (props) => {
    return (<Link to={!props.disable && props.link} ><div className="profile-sidebar-item" onClick={props.onClick}>
        <Icon style={{color: "#595959", margin: 0}}>{props.icon}</Icon> <span
        className="item-title">{props.title}</span>
    </div> </Link>)
};
const SideBarProfileJobber = (props) => {
    const items = [
        {
            title: props.data.suspend ? "Delete Suspending" : "Suspend",
            icon: "highlight_off"
        },
        {
            title: "All Requests",
            icon: "emoji_flags",
            link: "/dashboard/requests/" + props.data.id
        },
        {
            title: "Last Request",
            icon: "chevron_right",
            link: "/dashboard/request/" + props.data.lastRequestId,
            disable: props.data.lastRequestId == null
        },
        {
            title: "Last Accepted Request",
            icon: "last_page",
            link: "/dashboard/request/" + props.data.lastAcceptedRequestId,
            disable: props.data.lastAcceptedRequestId == null
        },
        {
            title: "Push Notification",
            icon: "notifications_none",
            link: "/dashboard/notification/" + props.data.id +"|" + props.data.name + " " + props.data.family,
        },
        {
            title: "Documents",
            icon: "wallpaper",
            link: "/dashboard/docs/" + props.data.id,
        },
        {
            title: "Deposits",
            icon: "compare_arrows",
            link: "/dashboard/deposits/" + props.data.id,
        }
    ];
    const [openConfirmDialog,setOpenConfirmDialog] = useState(false);
    const sendSuspendRequest = async (isDeleteRequest) => {
        const response = await axios.post(`/suspend/${isDeleteRequest ? 'delete' : 'add'}`,{user_id: props.data.id});
        if (!isDeleteRequest) props.data.suspend = response.data.data;
        else props.data.suspend = null;
        setOpenConfirmDialog(false);
    };

    return (<>
        <img className={"profile-avatar"} src={props.data.avatar}/>
        {props.data.jobs.findIndex(e=>e.status === "online") > -1 && <div className="profile-status">Online</div>}
        <div className="rating">
            <div className={"stars"}>
                <Rating name="read-only"
                        value={parseFloat(props.data.rate)}
                        style={{margin: 'auto'}}
                        readOnly
                        emptyIcon={<img src={"/assets/images/star_empty.svg"} style={{marginRight: '2px'}}/>}
                        icon={<img src={"/assets/images/star_fill.svg"} style={{marginRight: '2px'}}/>}
                        size={"medium"}/>
            </div>
            {props.data.rate || 0} ({props.data.total_comment || 0})
        </div>
        <div className="profile-info">
            <div className="profile-info-name capitalize">{props.data.name} {props.data.family}</div>
            <div className="profile-info-meta">{props.data.phone_number}</div>
            <div className="profile-info-meta">{props.data.identifier}</div>
        </div>

        {items.map((e,index) => {
            return <ItemClickableList title={e.title} icon={e.icon} link={e.link} disable={e.disable} onClick={item => {
                if (index === 0) {
                    setOpenConfirmDialog(true);
                }
            }
            }/>
        })}
        <ConfirmDialog
            open={openConfirmDialog}
            handleClose={() => {setOpenConfirmDialog(false);}}
            titleDialog={props.data.suspend ? "Delete Suspending" : "Suspend"}
            contentDialog={props.data.suspend ? "are you sure to delete suspending of user? if you delete suspending he/she can use the app" : "are you sure to suspend this user?"}
            onOKPressed={async () => {
                await sendSuspendRequest(props.data.suspend)
            }}
        />
    </>);
};

const AboutMeJobber = (props) => {
    const [iban,setIban] = useState('');
    const [period,setPeriod] = useState(1);
    const [openConfirmDialog,setOpenConfirmDialog] = useState(false);
    const [openSnackError,setOpenSnackError] = useState(false);

    useEffect(() => {
        setIban(props.data.statics.card_number);
        setPeriod(props.data.statics.pony_period)
    },[props.data.statics]);
    const handleChange = (e) => {
        setPeriod(e.target.value)
    };
    const sendNewData = () => {
        axios.post('/jobber/edit', {"iban": iban,
            "period": period,
            "jobber_id": props.data.id})
            .then(response => {
                setOpenConfirmDialog(false)
                if (!response.data.success) {
                    setOpenSnackError(true)
                }
        });
    };

    return (<>
        <h1>About Me</h1>
        <p>{props.data.about_us}</p>
        <div className="detail-about-me">
            <div className="detail-about-item">
                <b className="key">Gender:</b> {props.data.gender === true ? "Man" : props.data.gender === false ? "Woman" : "unknown"}
            </div>
            <div className="detail-about-item">
                <b className="key">Birthday:</b> {props.data.birthday &&  new Date(props.data.birthday).toLocaleDateString("en-US", {timeZone: "Europe/Zurich"})}
            </div>
            <div className="detail-about-item">
                <b className="key">Email:</b> {props.data.email}
            </div>
            <div className="detail-about-item">
                <b className="key">Zip:</b> {props.data.zip_code}
            </div>
            <div className="detail-about-item">
                <b className="key">Address:</b> {props.data.address}
            </div>
        </div>

        <div className="about-me-editable">
            <div className="editable-information-box">
                <b>IBAN</b>
                <input type="text" className="borderless" defaultValue={iban} value={iban} onChange={e => {setIban(e.target.value)}}/>
                <b> Period </b>
                <FormControl>
                    <Select
                        style={{marginLeft: '10px'}}
                        value={period}
                        onChange={handleChange}
                        displayEmpty
                        inputProps={{'aria-label': 'Without label'}}
                    >
                        <MenuItem value={1}>daily</MenuItem>
                        <MenuItem value={7}>weekly</MenuItem>
                        <MenuItem value={30}>monthly</MenuItem>
                    </Select>
                </FormControl>

            </div>
            <div className="save-button" onClick={e => {setOpenConfirmDialog(true)}}>Save</div>
        </div>

        <ConfirmDialog
            open={openConfirmDialog}
            handleClose={() => {setOpenConfirmDialog(false);}}
            titleDialog={`Change Iban And Pony Period`}
            contentDialog="you are changing the iban and period of this jobber are you sure?"
            onOKPressed={async () => {
                await sendNewData()
            }}
        />
        <SnackErrorVariant
            open={openSnackError}
            handleClose={() => {setOpenSnackError(false)}}
        />
    </>)
};

const JobberJobs = (props) => {

    return (<div className="jobber-jobs">
        <h1 style={{marginTop: '50px'}}>Jobs</h1>

        {props.jobs.map(job => {
            return (
                <div className="services">
                    <h3>{job.title} {job.status && <span className={job.status === "offline" && "offline"}>({new Date(job.status_created_time).toLocaleTimeString()})</span>}</h3>
                    <table>
                        {
                            job.services.map((service) => {
                                return (<>
                                    <tr className={service.deletedAt && 'unavailable'}>
                                        <td className="title-row">{service.service_title}</td>
                                        <td>{service.deletedAt && 'unavailable'}</td>
                                        <td>{service.price} CHF</td>
                                        <td>per {service.unit_title || 'hour'}</td>
                                    </tr>
                                </>)
                            })
                        }
                    </table>
                </div>
            )
        })}
    </div>)
};

const Profile = (props) => {
    const id = props.match.params.id;
    const [loading,setLoading] = useState(true);
    const [data, setData] = useState({});
    useEffect(() => {
        fetchUserData(id).then(response => {
            setData(response);
            setLoading(false)
        })
    }, []);
    return (
        <>
            {loading ? <div className='loading'>
                    <CircularProgress/>
                </div> :
                <div className="profile-container">
                    <div className="profile-main-container">
                        <Tags tags={data.tags}/>
                        <div className="soft-shadow-box">
                            <AboutMeJobber data={data}/>
                            {data.jobs.length > 0 && <JobberJobs jobs={data.jobs}/> }
                        </div>
                    </div>
                    <div className="profile-sidebar">
                        <SideBarProfileJobber data={data}/>
                    </div>
                </div>
            }
        </>
    )
};

export default Profile;
