import React from 'react';

const styles = {
    width: '150px',
    float: 'right'

}

class ChatSideBar extends React.Component {
    constructor(props) {
        super(props)
    }

    render() {
        return (
            <div
                style={styles} >
                <p>stuff</p>
                <p>stuff</p>
            </div>
        )
    }
}

export default ChatSideBar