import web3 from './web3';
import CampaignFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
    JSON.parse(CampaignFactory.interface),
    '0xFC237dFBf474250B0B244702F2e2ee5763e8bce2'
)

export default instance;
