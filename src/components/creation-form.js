import React from 'react';
import { connect } from 'react-redux'
import swal from 'sweetalert2'
import { createProject } from '../ethereum/requests/requests'

class CreationForm extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            projectName: '',
            description: '',
            totalRounds: '',
            starterFile: ''
        }
    }

    //project name
    //description
    //total rounds
    //starter file


    handleChangeFor = (event) => {
        this.setState({
            [event.target.name]: event.target.value
        })
    }

    submitProject = () => {
        let r = this.state
        if (r.projectName !== 0 && r.description !== 0 && r.totalRounds !== 0 && r.starterFile !== 0) {
            swal.fire({
                title: 'are you sure you are ready?',
                confirmButtonText: 'Yes',
                cancelButtonText: 'No'
            })
                .then((cowabunga) => {
                    if (cowabunga) {
                        createProject(r.projectName, r.description, r.totalRounds, r.starterFile);
                        swal.fire({
                            title: 'COWABUNGA IT IS!',
                            imageUrl: 'https://i.kym-cdn.com/entries/icons/original/000/027/747/michelangelo.jpg'
                        })

                    }
                    else {
                        swal('...pussy')
                    }
                })
        }
        else {
            swal({
                title: 'please fill out form'
            })
        }
    }

    render() {
        return (
            <div>
                <input
                    type="text"
                    name="projectName"
                    placeholder="Project Name"
                    onChange={this.handleChangeFor}
                    value={this.state.projectName}
                />
                <input
                    type="text"
                    name="description"
                    placeholder="description"
                    onChange={this.handleChangeFor}
                    value={this.state.description}
                />
                <input
                    type="number"
                    name="totalRounds"
                    placeholder="total rounds"
                    onChange={this.handleChangeFor}
                    value={this.state.totalRounds}
                />
                <input
                    type="text"
                    name="starterFile"
                    placeholder="starter file"
                    onChange={this.handleChangeFor}
                    value={this.state.starterFile}
                />
                <button onClick={this.submitProject}>submit</button>

            </div>
        )
    }
}

const mapStateToProps = state => ({
    state
})

export default connect(mapStateToProps)(CreationForm)