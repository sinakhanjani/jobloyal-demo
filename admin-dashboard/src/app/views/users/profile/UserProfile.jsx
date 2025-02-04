import React, {useEffect, useState} from "react";
import axios from "axios";
import "../../categories/treeview.scss"
import "../../jobbers/profile/Profile.scss"
import Icon from "@material-ui/core/Icon";
import Tags from "../../common/Tags";
import CircularProgress from "@material-ui/core/CircularProgress";
import ConfirmDialog from "../../common/ConfirmDialog";
import {Link} from "react-router-dom";

const fetchUserData = async (id) => {
    const response = await axios.get('/user/' + id);
    return response.data.data
};

const ItemClickableList = (props) => {
    return (<Link to={!props.disable && props.link} ><div className="profile-sidebar-item" onClick={props.onClick}>
        <Icon style={{color: "#595959", margin: 0}}>{props.icon}</Icon> <span
        className="item-title">{props.title}</span>
    </div> </Link>)
};
const SideBarProfileUser = (props) => {
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
            link: "/dashboard/request/" + props.data.last_request_id,
            disable: props.data.last_request_id == null
        },
        {
            title: "Push Notification",
            icon: "notifications_none",
            link: "/dashboard/notification/" + props.data.id +"|" + props.data.name + " " + props.data.family,
        },
        {
            title: "Payments",
            icon: "credit_card",
            link: "/dashboard/payments/" + props.data.id,
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
        <div className="profile-info">
            <div className="profile-info-name capitalize">{props.data.name} {props.data.family}</div>
            <div className="profile-info-meta">{props.data.phone_number}</div>
        </div>
        {items.map((e, index) => {
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

const AboutMeUser = (props) => {
    return (<>
        <h1>About Me</h1>
        <div className="detail-about-me user-row">
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
    </>)
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
                            <AboutMeUser data={data}/>
                        </div>
                    </div>
                    <div className="profile-sidebar">
                        <SideBarProfileUser data={data}/>
                    </div>
                </div>
            }
        </>
    )
};

export default Profile;
