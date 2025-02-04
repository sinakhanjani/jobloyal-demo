import React, {useEffect, useState} from "react";
import axios from "axios";
import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import TextField from "@material-ui/core/TextField";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";

const AddTwoLanguageDialog = (props) => {
    const {handleClose,open,onAddBtnPressed,dialogTitle,dialogContentText} = props;
    const [title,setTitle] = useState({en: '',fr: ''});
    return (<>
        <Dialog
            open={open}
            onClose={handleClose}
            aria-labelledby="form-dialog-title"
        >
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
                    onChange={(e) => {title.en = e.target.value}}
                    style={{float:'left',marginRight: '12px',width:'calc(50% - 6px)'}}
                />
                <TextField
                    margin="dense"
                    id="name_fr"
                    label="titre en langue française"
                    type="text"
                    required
                    onChange={(e) => {title.fr = e.target.value}}
                    style={{float:'left',width:'calc(50% - 6px)'}}
                />
            </DialogContent>
            <DialogActions>
                <Button variant="outlined" color="secondary" onClick={handleClose}>
                    Cancel
                </Button>
                <Button onClick={() => {
                    onAddBtnPressed(title)
                }} color="primary">
                    Add
                </Button>
            </DialogActions>
        </Dialog>
        </>)
};

export default AddTwoLanguageDialog
