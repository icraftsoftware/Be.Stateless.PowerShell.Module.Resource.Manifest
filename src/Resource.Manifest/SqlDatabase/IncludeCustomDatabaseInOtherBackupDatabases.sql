/*
Copyright © 2012 - 2020 François Chabot

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

USE [BizTalkMgmtDb]
GO

-- see https://docs.microsoft.com/en-us/biztalk/core/how-to-back-up-custom-databases

MERGE INTO [adm_OtherBackupDatabases] WITH (HOLDLOCK) AS [TARGET]
   USING (SELECT '$(CustomDatabaseName)' AS [DatabaseName], '$(ServerName)' AS [ServerName], '$(BTSServer)' AS [BTSServerName]) AS [SOURCE]
   ON [TARGET].[DatabaseName] = [SOURCE].[DatabaseName]
WHEN MATCHED THEN
   UPDATE SET [DefaultDatabaseName] = [SOURCE].[DatabaseName],
              [DatabaseName] = [SOURCE].[DatabaseName],
              [ServerName] = [SOURCE].[ServerName],
              [BTSServerName] = [SOURCE].[BTSServerName]
WHEN NOT MATCHED THEN
   INSERT ([DefaultDatabaseName],
          [DatabaseName],
          [ServerName],
          [BTSServerName])
   VALUES ([SOURCE].[DatabaseName],
          [SOURCE].[DatabaseName],
          [SOURCE].[ServerName],
          [SOURCE].[BTSServerName]);
GO

-- ensure a full backup is taken next time a backup is scheduled, otherwise backup of log will fail
-- as there won't be any previous full backup of the new custom database
EXEC sp_ForceFullBackup
GO