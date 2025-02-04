export const SET_SEARCH_PLAIN_TEXT = "SET_SEARCH_PLAIN_TEXT";

export function setSearchPlainText(text) {
    return dispatch => {
        dispatch({
            type: SET_SEARCH_PLAIN_TEXT,
            text: text
        });
    };
}
