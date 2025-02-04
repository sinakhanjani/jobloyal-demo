import React, {useEffect, useState} from "react";
import Dialog from "@material-ui/core/Dialog";
import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";

const ConfirmDialog = (props) => {
    const {open,handleClose,titleDialog,contentDialog, onOKPressed} = props

    return ( <Dialog
        open={open}
        onClose={handleClose}
        aria-labelledby="alert-dialog-title"
        aria-describedby="alert-dialog-description"
    >
        <DialogTitle id="alert-dialog-title">
            {titleDialog}
        </DialogTitle>
        <DialogContent>
            <DialogContentText id="alert-dialog-description">
                {contentDialog}
            </DialogContentText>
        </DialogContent>
        <DialogActions>
            <Button onClick={handleClose} color="primary">
                Disagree
            </Button>
            <Button onClick={onOKPressed} color="primary" autoFocus>
                Agree
            </Button>
        </DialogActions>
    </Dialog>)
};

export default ConfirmDialog
