# Synopsis

Enterprise Caching System (zECS) is a cloud enabled distributed key/value pair caching service in the z/OS environment. Very high performing and high available system used to store text or binary content. Single instances can be shared by multiple clients or unique instances can be defined for each individual client. 

- L2 Distributed write thru cache to persistent disk
- Key/Value structure
  - Key can be from 1 to 255 bytes
  - Key names are case sensitive, "Rangers" is different than "rangers".
  - Key cannot contain embedded spaces.
  - Value can be from 1 byte to 3.2 Megabytes
  - Both text and binary data values are accepted.
- HTTP/HTTPS transmission depending on if data is needing to be secured in transit
- Transactional based system (geared for high volume I/O)
- Basic authentication access (RACF security) for CRUD operations
- ACID compliant (Atomic, Consistent, Isolation, Durable)
- RESTful service supporting:
  - GET:    Retrieve key/value
  - POST:   Writes key/value to instance, creates new keys and updates existing key values.
  - PUT:    Writes key/value to instance, creates new keys and updates existing key values.
  - DELETE: Delete a key/value from the instance
- Built-in expiration process.
- Clear entire cache instance with single request
- Six Sigma Availablility:
  - Active/Single (High Availability at a single data center)
  - Active/Standby (High Availability across multiple data centers)
  - Active/Active (Continuous Availability across multiple data centers)
  
As part of the product there is a built-in expiration process that runs automatically in the background. Refer to the installation instructions on setting up zECS instances. Expiration process continually scans the zECS data looking for keys that have expired and removes them. There are no additional web service calls required to initiate or trigger this component. Based on max time to live values, keys will never live more than 24 hours.

## About this project 

Please refer to the following locations for additional info regarding this project:

- [System Requirements and Considerations.md](./System%20Requirements%20and%20Considerations.md) for minimum software version requirements and key environment configuration considerations
- [Installation.md](./Installation.md) for instructions on installing and setting up this service
- [Usage.md](./Usage.md) for API descriptions, sample code snippets for consuming the service, other usage related details

### Contributors

- **_Randy Frerking_**,	Walmart Technology
- **_Rich Jackson_**, Walmart Technology
- **_Michael Karagines_**, Walmart Technology
- **_Trey Vanderpool_**, Walmart Technology

