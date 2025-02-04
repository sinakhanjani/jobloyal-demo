import {
    SET_SEARCH_PLAIN_TEXT
} from "../actions/SearchAction";

const initialState = {};

const userReducer = function(state = initialState, action) {
    switch (action.type) {
        case SET_SEARCH_PLAIN_TEXT: {
            return {
                ...state,
                text: action.text
            };
        }
        default: {
            return state;
        }
    }
};

export default userReducer;
