# memoapi.api.UserControllerApi

## Load the API package
```dart
import 'package:memoapi/api.dart';
```

All URIs are relative to *http://localhost:8080*

Method | HTTP request | Description
------------- | ------------- | -------------
[**create**](UserControllerApi.md#create) | **POST** /memo-io-back/users | 
[**deleteById**](UserControllerApi.md#deletebyid) | **DELETE** /memo-io-back/users/{id} | 
[**getAll**](UserControllerApi.md#getall) | **GET** /memo-io-back/users | 
[**getById**](UserControllerApi.md#getbyid) | **GET** /memo-io-back/users/{id} | 
[**login**](UserControllerApi.md#login) | **POST** /memo-io-back/users/login | 
[**updateById**](UserControllerApi.md#updatebyid) | **PUT** /memo-io-back/users/{id} | 


# **create**
> Object create(userCreateDTO)



Endpoint para adicionar um usuário

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = UserControllerApi();
final userCreateDTO = UserCreateDTO(); // UserCreateDTO | 

try {
    final result = api_instance.create(userCreateDTO);
    print(result);
} catch (e) {
    print('Exception when calling UserControllerApi->create: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userCreateDTO** | [**UserCreateDTO**](UserCreateDTO.md)|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **deleteById**
> Object deleteById(id)



Endpoint para deletar um usuário pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = UserControllerApi();
final id = 789; // int | 

try {
    final result = api_instance.deleteById(id);
    print(result);
} catch (e) {
    print('Exception when calling UserControllerApi->deleteById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getAll**
> Object getAll()



Endpoint para listar todos os usuários

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = UserControllerApi();

try {
    final result = api_instance.getAll();
    print(result);
} catch (e) {
    print('Exception when calling UserControllerApi->getAll: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **getById**
> Object getById(id)



Endpoint para exibir os dados de um usuário pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = UserControllerApi();
final id = 789; // int | 

try {
    final result = api_instance.getById(id);
    print(result);
} catch (e) {
    print('Exception when calling UserControllerApi->getById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **login**
> Object login(userLoginDTO)



Endpoint para fazer login

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = UserControllerApi();
final userLoginDTO = UserLoginDTO(); // UserLoginDTO | 

try {
    final result = api_instance.login(userLoginDTO);
    print(result);
} catch (e) {
    print('Exception when calling UserControllerApi->login: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **userLoginDTO** | [**UserLoginDTO**](UserLoginDTO.md)|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **updateById**
> Object updateById(id, userUpdateDTO)



Endpoint para atualizar os dados de um usuário pelo ID

### Example
```dart
import 'package:memoapi/api.dart';

final api_instance = UserControllerApi();
final id = 789; // int | 
final userUpdateDTO = UserUpdateDTO(); // UserUpdateDTO | 

try {
    final result = api_instance.updateById(id, userUpdateDTO);
    print(result);
} catch (e) {
    print('Exception when calling UserControllerApi->updateById: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**|  | 
 **userUpdateDTO** | [**UserUpdateDTO**](UserUpdateDTO.md)|  | 

### Return type

[**Object**](Object.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: */*

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

