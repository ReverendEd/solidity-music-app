import React from 'react'
import TextField from '@material-ui/core/TextField'


class SearchBar extends React.Component{

    render(){
        return(
            <TextField
          id="standard-name"
          label="Search"

          margin="normal"
        />
        )
    }
}

export default SearchBar