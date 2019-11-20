---------- METADATA CREATION ----------

CREATE TABLE BOSTON_HOUSING
(
   ID        NUMBER,
   CRIM      NUMBER,
   ZN        NUMBER,
   INDUS     NUMBER,
   CHAS      NUMBER,
   NOX       NUMBER,
   RM        NUMBER,
   AGE       NUMBER,
   DIS       NUMBER,
   RAD       NUMBER,
   TAX       NUMBER,
   PTRATIO   NUMBER,
   BLACK     NUMBER,
   LSTAT     NUMBER,
   MEDV      NUMBER
);


CREATE TABLE BOSTON_HOUSING_TEST
(
   ID        NUMBER,
   CRIM      NUMBER,
   ZN        NUMBER,
   INDUS     NUMBER,
   CHAS      NUMBER,
   NOX       NUMBER,
   RM        NUMBER,
   AGE       NUMBER,
   DIS       NUMBER,
   RAD       NUMBER,
   TAX       NUMBER,
   PTRATIO   NUMBER,
   BLACK     NUMBER,
   LSTAT     NUMBER,
   MEDV      NUMBER
);

---------- DATA LOAD ----------

BEGIN
    dbms_cloud.create_credential(   credential_name => 'OBJ_STORE_CRED2', 
                                    username => 'CLOUD USER COMPARTMENT', 
                                    password => 'CLOUD USER COMPARTMENT TOKEN'
                                );
END;

BEGIN
    dbms_cloud.copy_data(   table_name => 'BOSTON_HOUSING',
                            credential_name => 'OBJ_STORE_CRED2', 
                            file_uri_list => 'https://swiftobjectstorage.regino_name.oraclecloud.com/v1/tenancy_name/bucket_name/train.csv',
                            format => JSON_OBJECT(  'delimiter' VALUE ',', 'ignoremissingcolumns' VALUE 'true',
                                                    'removequotes' VALUE 'true', 'skipheaders' VALUE '1'));
                                                    
    dbms_cloud.copy_data(   table_name => 'BOSTON_HOUSING_TEST',
                            credential_name => 'OBJ_STORE_CRED2', 
                            file_uri_list => 'https://swiftobjectstorage.region_name.oraclecloud.com/v1/tenancy_name/bucket_name/test.csv',
                            format => JSON_OBJECT(  'delimiter' VALUE ',', 'ignoremissingcolumns' VALUE 'true',
                                                    'removequotes' VALUE 'true', 'skipheaders' VALUE '1'));
END;

---------- DATA LOAD TEST ----------
select * from BOSTON_HOUSING;

select * from BOSTON_HOUSING_TEST;


---------- MODEL BUILD ----------
DROP TABLE neural_network_settings;

CREATE TABLE neural_network_settings (
    setting_name    VARCHAR2(1000),
    setting_value   VARCHAR2(1000)
);

BEGIN
    INSERT INTO neural_network_settings (
        setting_name,
        setting_value
    ) VALUES (
        dbms_data_mining.prep_auto,
        dbms_data_mining.prep_auto_on
    );

    INSERT INTO neural_network_settings (
        setting_name,
        setting_value
    ) VALUES (
        dbms_data_mining.algo_name,
        dbms_data_mining.algo_neural_network
    );
    
    INSERT INTO neural_network_settings (
        setting_name,
        setting_value
    ) VALUES (
        dbms_data_mining.nnet_activations,
        '''NNET_ACTIVATIONS_LOG_SIG'',''NNET_ACTIVATIONS_LOG_SIG'',''NNET_ACTIVATIONS_LOG_SIG'''
    );

    INSERT INTO neural_network_settings (
        setting_name,
        setting_value
    ) VALUES (
        dbms_data_mining.nnet_nodes_per_layer,
        '512,250,100'
    );
    
    INSERT INTO neural_network_settings (
        setting_name,
        setting_value
    ) VALUES (
        dbms_data_mining.nnet_iterations,
        250
    );


    COMMIT;
END;

BEGIN
   BEGIN
    DBMS_DATA_MINING.DROP_MODEL('DEEP_LEARNING_MODEL');
   EXCEPTION
    WHEN OTHERS THEN
    NULL;
   END; 

   DBMS_DATA_MINING.CREATE_MODEL(
      model_name          => 'DEEP_LEARNING_MODEL',
      mining_function     => dbms_data_mining.regression,
      data_table_name     => 'BOSTON_HOUSING',
      case_id_column_name => 'ID',
      target_column_name  => 'MEDV',
      settings_table_name => 'neural_network_settings');
END;


select * from neural_network_settings;

select * from all_mining_model_settings where model_name='DEEP_LEARNING_MODEL';

---------- TRAINING DETAILS ----------

select * from DM$VADEEP_LEARNING_MODEL;

select * from DM$VGDEEP_LEARNING_MODEL;

select * from DM$VNDEEP_LEARNING_MODEL;


---------- MODEL TEST ----------

SELECT
    t.*,
    PREDICTION(deep_learning_model USING *) pred
FROM
    boston_housing_test t;

