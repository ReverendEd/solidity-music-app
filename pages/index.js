import React, { Component } from 'react';
import factory from '../ethereum/factory'
import { Button } from 'semantic-ui-react'

class CampaignIndex extends Component {
    static async getInitialProps() {
        const campaigns = await factory.methods.getDeployedCampaigns().call()
        console.log(campaigns);
        return { campaigns }
    }

    render() {
        return (
            <div>
                {this.props.campaigns[0]}
                <Button>hi</Button>
            </div>
        )
    }
}

export default CampaignIndex