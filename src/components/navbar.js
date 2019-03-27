import React from 'react';
import { connect } from 'react-redux';
import { Link } from 'react-router-dom'
import { Button, Toolbar } from '@material-ui/core'

const Create = props => <Link to="/create" {...props} />
const Browse = props => <Link to="/browse" {...props} />
const Search = props => <Link to="/search" {...props} />
const Relax = props => <Link to="/relax" {...props} />
const Projects = props => <Link to="/projects" {...props} />
const Workspace = props => <Link to="/home" {...props} />


class NavBar extends React.Component {
    constructor(props) {
        super(props)
    }



    render() {
        return (
            <div>
                <Toolbar
                    display='flex'
                    height={150}
                    margin={0} >

                    <Button component={Create}>
                        Create
                    </Button>
                    <Button component={Browse}>
                        Browse
                    </Button>
                    <Button component={Search}>
                        Search
                    </Button>
                    <Button component={Relax}>
                        Relax
                    </Button>
                    <Button component={Projects}>
                        Projects
                    </Button>
                    <Button component={Workspace}>
                        Workspace
                    </Button>


                </Toolbar>

            </div >
        )
    }
}

const mapStateToProps = state => ({
    state
});



export default connect(mapStateToProps)(NavBar)