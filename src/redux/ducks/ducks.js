// import Cookies from 'universal-cookie';
// const cookies = new Cookies

// this stores simple variables. nothing super complicated 

class DUCKS {
    constructor(){
        this.state = {};
        this.namesList = [];
    }

    post = (name, data)=>{
        this.state[`${name}`] = data
        this.namesList.push(name)
    }

    get = (name)=>{
        if (this.state[`${name}`] && this.state[`${name}`] !== '') {
            return this.state[`${name}`] 
        }
        else{
            return '';
        }
    }

    update = (name, data)=>{
        if (this.state[`${name}`]) {
            this.state[`${name}`] = data
        }
        else{
            console.log('this variable has never been defined');
        }
    }

    delete = (name)=>{
        if (this.state[`${name}`] && this.state[`${name}`] !== '') {
            this.state[`${name}`] = ''
        }
        else{
            console.log('this variable doesnt exist or has already been deleted.');
        }
    }

    getNames = ()=>{
        console.log(this.names)
        return this.namesList
    }


}

let duck = new DUCKS()

export default duck