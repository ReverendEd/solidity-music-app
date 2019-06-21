import React from 'react';
import Nav from '../components/navbar'
import FavoritesSidebar from '../components/favorites-sidebar'
import SearchBar from '../components/searchbar'

class BrowseView extends React.Component{



    render(){
        return(
            <div> 
                <Nav />
                <FavoritesSidebar />
                <SearchBar />
            </div>
        )
    }
}

export default BrowseView