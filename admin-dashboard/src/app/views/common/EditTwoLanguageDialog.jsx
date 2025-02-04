import React, {useEffect, useState} from "react";
import axios from "axios";
import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import TextField from "@material-ui/core/TextField";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";

const EditTwoLanguageDialog = (props) => {
    const {handleClose,open,onEditBtnPressed,dialogTitle,dialogContentText,oldTitle} = props;
    const [fr,setFr] = useState('');
    const [en,setEn] = useState('');
    useEffect(() => {
        if (oldTitle) {
            setEn(oldTitle.en);
            setFr(oldTitle.fr);
        }
    },[oldTitle]);
    return (<>
        <Dialog
            open={open}
            onClose={handleClose}
            aria-labelledby="form-dialog-title">
            <DialogTitle id="form-dialog-title">{dialogTitle}</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    {dialogContentText}
                </DialogContentText>
                <TextField
                    autoFocus
                    margin="dense"
                    id="name_en"
                    label="title in english language"
                    type="text"
                    required
                    defaultValue={en}
                    onChange={(e) => {setEn(e.target.value)}}
                    style={{float:'left',marginRight: '12px',width:'calc(50% - 6px)'}}
                />
                <TextField
                    margin="dense"
                    id="name_fr"
                    label="titre en langue française"
                    type="text"
                    required
                    defaultValue={fr}
                    onChange={(e) => {setFr(e.target.value)}}
                    style={{float:'left',width:'calc(50% - 6px)'}}
                />
            </DialogContent>
            <DialogActions>
                <Button variant="outlined" color="secondary" onClick={handleClose}>
                    Cancel
                </Button>
                <Button onClick={() => {
                    onEditBtnPressed({en: en, fr: fr})
                }} color="primary">
                    Edit
                </Button>
            </DialogActions>
        </Dialog>
    </>)
};

export default EditTwoLanguageDialog
