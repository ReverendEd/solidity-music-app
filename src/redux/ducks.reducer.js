import { combineReducers } from 'redux';
import newDuck from './ducks/ducks';



const duck = (state = newDuck.state, action) => {
    switch (action.type) {
        case 'get':
            return newDuck.state;
        case 'post':
            newDuck.post(action.name, action.data)
            return newDuck.state;
        case 'update':
            newDuck.update(action.name, action.data)
            return newDuck.state;
        case 'delete':
            newDuck.delete(action.name, action.data)
            return newDuck.state;
        default:
            return state;
    }
};




export default duck