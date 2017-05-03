# Usage

## Code Examples

Variables used in these examples:  
    - **_hostname:port_** values are all site specific  
    - **_@path@_** is defined by the team that sets up the zUID service  
    - **_@key@_** is 1 to 255 character value that represents the key

### curl:
- Retrieve a value from the zECS instance.
```curl -X GET "http://hostname:port@path@@key@"```
	
- Put a new key value onto the zECS instance.
```curl -X POST "http://hostname:port@path@@key@" (value...)```
	
- Delete a key from the instance.
```curl -X DELETE "http://hostname:port@path@@key@"```
	
### COBOL CICS:
- Refer to [readme_COBOL_ex1](./readme_COBOL_ex1.md). Shows an insert, retrieve and delete for a key.
	
### Standard browser (Chrome, IE, Safari):
- Can only submit GET requests from the browser. Will need other tools like ARC (Advanced REST Client), DCH REST Client, SOAP-UI or Postman to execute additional requests with POST/PUT/DELETE.
	
	Retrieve the value for specified key:
	http://hostname:port@path@/@key@
	
### JavaScript:

- This small snippet of code will show how to write, read and delete a key/value pair to the zECS instance.
	
    ```javascript
	var svc = new XMLHttpRequest();
	var url = "http://hostname:port@path@";
	var key_name = "mlb_dodgers"
	var ecs_value = "{ \"name\":\"Los Angeles Dodgers\", \"players\":26, \"salaries\":248606156, \"won_world_series\" : true }";
	// Put a key value onto the zECS instance
	svc.open( "POST", url + key_name, false );
	svc.setRequestHeader("Content-type", "text/plain");
	svc.send( ecs_value );
	alert("POST Dodgers to zECS: " + "Status=" + svc.status + ":" + svc.statusText + "\nResponse=" + svc.responseText );
	// On return we get HTTP status:200 with status text:Ok
	
	// Retrieve the mlb_dodgers key from the zECS instance
	svc.open( "GET", url + key_name, false );
	svc.send( null );
	alert("GET Dodgers from zECS: " + "Status=" + svc.status + ":" + svc.statusText + "\nResponse=" + svc.responseText );
	// On return we get HTTP status:200 with status text:Ok
	// Return key value:{ "name":"Los Angeles Dodgers", "players":26, "salaries":248606156, "won_world_series" : true }
	
	// Delete the dodgers from the zECS instance.
	svc.open( "DELETE", url + key_name, false );
	svc.send( ecs_value );
	alert("DELETE Dodgers from zECS: " + "Status=" + svc.status + ":" + svc.statusText + "\nResponse=" + svc.responseText );
	// On return we get HTTP status:200 with status text:Ok
    ```

## HTTP Status Codes
- 200 - Success
- 204 - Record not found
- 400 - WEB RECEIVE error
- 400 - Invalid URI format
- 400 - Key exceeds maximum 255 bytes
- 400 - Key must be greater than 0 bytes
- 401 - Basic Authentication failed
- 409 - Duplicate key
- 507 - ZCxxKEY error
- 507 - ZCxxFILE error
    

## Installation

Refer to the [installation instructions](./Installation.md) for complete setup in the z/OS environment.



## API Reference

### Query string parameters:
- ttl=99999
   This is only valid with the PUT/POST methods and specifies time to live in seconds for each key. It's a numeric value between 300 (5 minutes) and 86400 (24 hours) seconds. If not specified it defaults to 30 minutes or 1800 seconds. The built-in background expiration process automatically cleans up expired keys. 
- clear=*
   This is a request to clear all the keys from the zECS instance and only valid with the DELETE method.

### Example URL calls:
- GET - http://hostname:port@path@{up_to_255_byte_key}
	No body.
	
- POST - http://hostname:port@path@{up_to_255_byte_key}
	Requires a body containing the data to save under specified key.
	
- PUT - http://hostname:port@path@{up_to_255_byte_key}
	Requires a body containing the data to save under specified key.

- DELETE - http://hostname:port@path@{up_to_255_byte_key}
	No body. The key is removed from the instance.

	
### HTTP Headers
- None
