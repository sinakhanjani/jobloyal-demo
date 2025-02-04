import React, { Component } from "react";
import { Icon, IconButton } from "@material-ui/core";
import { withStyles } from "@material-ui/core/styles";
import {connect} from "react-redux";
import {setSearchPlainText} from "../../app/redux/actions/SearchAction";

const styles = theme => ({
  root: {
    backgroundColor: theme.palette.primary.main,
    color: theme.palette.primary.contrastText,
    "&::placeholder": {
      color: theme.palette.primary.contrastText
    }
  }
});

class MatxSearchBox extends Component {
  state = {
    open: false
  };
  constructor(props) {
    super(props);
    this.timeout =  0;
  }

  toggle = () => {
    if (this.state.open === true) {
      this.props.setSearchPlainText('')
    }
    this.setState({ open: !this.state.open });
  };
  doSearch(evt){
    const txt = evt.target.value;
    if(this.timeout) clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      this.props.setSearchPlainText(txt)
    }, 500);
  }
  render() {
    let { classes } = this.props;
    return (
      <React.Fragment>
        {!this.state.open && (
          <IconButton onClick={this.toggle}>
            <Icon>search</Icon>
          </IconButton>
        )}

        {this.state.open && (
          <div
            className={`flex items-center h-full matx-search-box ${classes.root}`}
          >
            <input
              className={`px-4 search-box w-full ${classes.root}`}
              type="text"
              placeholder="Search here..."
              onChange={(e) => {
                this.doSearch(e);
              }}
              autoFocus
            />
            <IconButton onClick={this.toggle} className="align-middle mx-4">
              <Icon>close</Icon>
            </IconButton>
          </div>
        )}
      </React.Fragment>
    );
  }
}

export default connect(null,{setSearchPlainText})(withStyles(styles, { withTheme: true })(MatxSearchBox));
