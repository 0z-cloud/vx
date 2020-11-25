# vx-sync Role in oz-interface - Provides bidirectional API IaC Cloud states interface

- Bidirectional tools for talking with you IaC Cloud Provider in Pipelines
- Manage some two-way dynamicly allocated objects, such like examples, -

  - for prevents use same network(s)/ip(s)/mac(s) and etc also things,
    in cases which all around template totally generated.

  - for stacking network zones in same mesh cloud network

  - for choice which way use when we works in pipeline with thats (ip/mac/network/etc) stored in provider placement -
    default case is, -
    [I] We generate something dataset for any (ip/mac/network/etc) property of an to applicate to a cloud instance objects
    [II] After we done the prepare generated result, we go to API of Cloud provider and store that variables library by any possible way (use roles as k/v as example if no are have a special section and methods in api for that, see vcd adapter)
    [III] On stage of mathing recieved answer from Cloud Provider we can get something like two types of state - 'changed', is say for us about first run of that environment bootstrap and we must to use generated dataset with variables specific at this environment chain pipelining. Other cases give are second type - 'ok', thats say for us about that object in Cloud Provider - he are a already prerents, and for continue invocation we must to read dataset from Cloud Provider Storage, and replaces him variables in current workflow run.
