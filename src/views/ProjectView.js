import React, { Component } from 'react';
import NavBar from '../components/navbar'
import SideBar from '../components/project-sidebar'
import ChatSideBar from '../components/chat-sidebar'
import BottomBar from '../components/bottombar'

const styles = {
    width: '100%',
    float: 'left'

}

class ProjectView extends Component {
    constructor(props) {
        super(props)
    }

    render() {
        return (
            <div
                className="grid-container"
                style={styles}>
                <NavBar />
                <SideBar />
                <ChatSideBar />
                <BottomBar />
            </div>
        )
    }
}

export default ProjectView