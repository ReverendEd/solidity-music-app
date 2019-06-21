import React from 'react'
import NavBar from '../components/navbar'
import FavoritesSideBar from '../components/favorites-sidebar'
import { connect } from 'react-redux'

class ProjectsPageView extends React.Component {
    constructor(props){
        super(props)
    }

    render(){
        return(
            <div>
                <NavBar />
                <FavoritesSideBar />
                this is the Projects Page View
            </div>
        )
    }
}

const mapStateToProps = state =>({
    state
})
export default connect(mapStateToProps)(ProjectsPageView)