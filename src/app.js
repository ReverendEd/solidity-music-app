import React from 'react';
import {
  HashRouter as Router,
  Route,
  Redirect,
  Switch,
} from 'react-router-dom';

import p2p from './p2p/p2p'
import ProjectView from './views/ProjectView'
import NavBar from './components/navbar'
import { connect } from 'react-redux';


const mapStateToProps = state => ({
  user: state.user,
});

class App extends React.Component {
  constructor(props) {
    super(props)



  }

  componentDidMount() {

  }



  render() {
    return (
      <div>
        <Router>
          <Switch>
            <Redirect exact from="/" to="/home" />
            <Route
              path="/home"
              component={ProjectView}
            />
            {/* OTHERWISE (no path!) */}
            <Route render={() => <div><NavBar/><h1>404</h1></div>} />

          </Switch>
        </Router>
      </div>
    );
  }
}

export default connect(mapStateToProps)(App);