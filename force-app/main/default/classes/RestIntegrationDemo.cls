public with sharing class RestIntegrationDemo {

    public class UserWrapper {
        public Integer id;
        public String name;
        public String username;
        public String email;
        public String phone;
        public String website;
    }

    public static UserWrapper getUserData() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint('https://jsonplaceholder.typicode.com/users/1');
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200){
            UserWrapper user = (UserWrapper) JSON.deserialize(response.getBody(), UserWrapper.class);
            return user;
        } else {
            System.debug('Error: ' + response.getBody());
            return null;
        }
    }
}