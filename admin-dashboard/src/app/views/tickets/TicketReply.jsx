import React, {useEffect, useState} from "react";
import SimpleCard from "../../../matx/components/cards/SimpleCard";
import Breadcrumb from "../../../matx/components/Breadcrumb";
import axios from "axios";
import {Grid, Icon, TableCell} from "@material-ui/core";
import {Link} from "react-router-dom";
import SuperTreeview from 'react-super-treeview';
import "../categories/treeview.scss"
import Tags from "../common/Tags";
import "../notification/PushNotification.scss";
import CircularProgress from "@material-ui/core/CircularProgress";
import { useHistory } from 'react-router-dom';

const getMessageData =  async (id) => {
    const response = await axios.post("/message", {id});
    return response.data.data;
};

const UserDetail = (props) => {
    const [loading, setLoading] = useState(false);
    const [contentOfPost, setContentOfPost] = useState("");
    const history = useHistory();

    const id = props.data.id;
    const sendNotification = () => {
        setLoading (true);
        const response = axios.post("/message/reply", {
            "message_id": id,
            "answer": contentOfPost
        }).then(response => {
            setLoading(false);
            if (response.data.success) {
                setContentOfPost("");
                history.goBack();
            }
        });
    };
    useEffect(() => {
        props.data.reply && setContentOfPost(props.data.reply.answer)
    }, []);
    return (<div className="push_message">
            <div>
                From:  <Link to={`/dashboard/${props.data.user.is_jobber ? "jobber" : "user"}/${props.data.user.id}`}
                             style={{display: "content"}}><b>{props.data.user.name} {props.data.user.family}</b></Link>
            </div>
            <div className="">
                {props.data.description}
            </div>


            <div className="white-box mt-2">
                        <textarea
                            value={contentOfPost}
                            placeholder="Type Your Reply Here..."
                            className="title-input"
                            readOnly={props.data.reply}
                            onChange={(e) => {setContentOfPost(e.target.value)}}
                        />
            </div>
            { !props.data.reply && <div className="right-end"> {loading ? <CircularProgress size={30}/> :
                <div className="send-button" onClick={e => {
                    if (!loading) sendNotification()
                }}>
                    Send
                </div>

            }
            </div>
            }
        </div>
    )
};

const UserInfo = (props) => {
    const s = props.match.params.id;
    const [loading, setLoading] = useState(true);
    const [data,setData] = useState({});

    useEffect(() => {
        getMessageData(s).then((response) => {
            setData(response);
            setLoading(false);
        })
    }, []);
    return ( <>
            {loading ? <div className='loading'>
                    <CircularProgress/>
                </div> :
                <div className="m-sm-30">
                    <div className="py-3"/>
                    <div style={{marginTop: '20px'}}>
                        <SimpleCard title={data.subject}>
                            <UserDetail data={data}/>
                        </SimpleCard>
                    </div>
                </div>
            }
        </>
    )
};

export default UserInfo
