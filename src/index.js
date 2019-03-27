import React from 'react';
import ReactDOM from 'react-dom';
import { createStore, applyMiddleware } from 'redux';
import { Provider } from 'react-redux';

import reducer from './redux';

import App from './app';


// Initializing to an empty object, but here is where you could
// preload your redux state with initial values (from localStorage, perhaps)
const preloadedState = {};

export const initializeP2P = () => {
  // initialize the p2p here, maybe initialize with no p2p at first? then update redux and make that do stuff stuff yes?

}

export const store = createStore(
  reducer,
  preloadedState,
  applyMiddleware(),
);

ReactDOM.render(
  <Provider store={store}>
    <App />
  </Provider>,
  document.getElementById('react-root'),
);
