import React from 'react';
import { connect } from 'react-redux'
import Nav from '../components/navbar'
import ProjectSidebar from '../components/project-sidebar'
import CreationForm from '../components/creation-form'

class NewProjectView extends React.Component{
    constructor(props){
        super(props)
    }



    render(){
        return(
            <div>
                <Nav />
                <ProjectSidebar />
                <CreationForm />
                <p> this is the New Project Page</p>
            </div>
        )
    }
}

const mapStateToProps = state => ({
    state
})

export default connect(mapStateToProps)(NewProjectView)