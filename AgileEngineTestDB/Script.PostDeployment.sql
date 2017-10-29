/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

:r .\_Script\StaticData\ProductTypeStatic.sql							
:r .\_Script\StaticData\CityStatic.sql									
:r .\_Script\StaticData\ProductDummyStatic.sql							
:r .\_Script\StaticData\StoreDummyStatic.sql							


