import DialogTitle from "@material-ui/core/DialogTitle";
import DialogContent from "@material-ui/core/DialogContent";
import DialogContentText from "@material-ui/core/DialogContentText";
import TextField from "@material-ui/core/TextField";
import DialogActions from "@material-ui/core/DialogActions";
import Button from "@material-ui/core/Button";
import Dialog from "@material-ui/core/Dialog";
import React, {useEffect, useState} from "react";
import MenuItem from "@material-ui/core/MenuItem";
import FormControl from "@material-ui/core/FormControl";
import InputLabel from "@material-ui/core/InputLabel";
import Select from "@material-ui/core/Select";
import FormControlLabel from "@material-ui/core/FormControlLabel";
import Checkbox from "@material-ui/core/Checkbox";


const AddVersionDialog = (props) => {
    const {open,handleClose,okButtonPressed} = props;
    const [description,setDescription] = useState('');
    const [versionCode,setVersionCode] = useState('');
    const [link,setLink] = useState('');
    const [force,setForce] = useState(false);
    const [device,setDevice] = useState("android");
    const [app,setApp] = useState(true); //app means update for jobber app?

    return (
        <Dialog
            open={open}
            onClose={handleClose}
            aria-labelledby="form-dialog-title"
        >
            <DialogTitle id="form-dialog-title">Add Version</DialogTitle>
            <DialogContent>
                <DialogContentText>
                    adding the version cause users see an alert in first page of application, when you check force update, users can't continue working with app till they update application
                </DialogContentText>

                <TextField
                    autoFocus
                    id="name_en"
                    label="description"
                    type="text"
                    required
                    multiline
                    margin="normal"
                    onChange={(e) => {setDescription(e.target.value)}}
                    fullWidth
                />
                <div style={{display: "flex",justifyContent: 'space-between',marginTop: '30px'}}>
                <FormControl variant="outlined" style={{width: 'calc(50% - 10px)'}}>
                    <InputLabel id="demo-simple-select-outlined-label">Device</InputLabel>
                    <Select
                        labelId="demo-simple-select-outlined-label"
                        id="device_type"
                        onChange={(e)=>{setDevice(e.target.value)}}
                        label="Device"
                    >
                        <MenuItem value="android">Android</MenuItem>
                        <MenuItem value="ios">iOS</MenuItem>
                    </Select>
                </FormControl>
                <FormControl variant="outlined" style={{width: 'calc(50% - 10px)'}}>
                    <InputLabel id="demo-simple-select-outlined-label">App</InputLabel>
                    <Select
                        labelId="demo-simple-select-outlined-label"
                        id="app_type"
                        onChange={(e)=>{setApp(e.target.value)}}
                        label="App"
                    >
                        <MenuItem value={false}>User</MenuItem>
                        <MenuItem value={true}>Jobber</MenuItem>
                    </Select>
                </FormControl>
                </div>
                <TextField
                    autoFocus
                    id="version_code"
                    label="version code"
                    type="number"
                    required
                    variant="outlined"
                    margin="normal"
                    onChange={(e) => {setVersionCode(e.target.value)}}
                    fullWidth
                />
                <TextField
                    autoFocus
                    id="link"
                    label="link"
                    type="text"
                    required
                    variant="outlined"
                    margin="normal"
                    onChange={(e) => {setLink(e.target.value)}}
                    fullWidth
                />
                <FormControlLabel
                    control={
                        <Checkbox
                            checked={force}
                            onChange={(e) => {setForce(e.target.checked)}}
                            name="checkedB"
                            color="primary"
                        />
                    }
                    label="All User Force To Update"
                />
            </DialogContent>
            <DialogActions>
                <Button variant="outlined" color="secondary" onClick={handleClose}>
                    Cancel
                </Button>
                <Button onClick={() => {
                    okButtonPressed({
                        "device_type": device,
                        "is_jobber_app": app,
                        "description": description,
                        "force": force,
                        "link": link,
                        "version_code": versionCode
                    })
                }} color="primary">
                    Add
                </Button>
            </DialogActions>
        </Dialog>
    )
}
export default AddVersionDialog
