-- =====================================================================
-- Author: Marco Bortolin, Andrea Dottor
-- Create date: 30/04/2019
-- Description: Migrate database from ASP.Net Identity to ASP.NET Core Identity (schema and data)
-- =====================================================================

SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;
SET NUMERIC_ROUNDABORT OFF;
GO

PRINT N'Dropping [dbo].[AspNetUserClaims].[IX_UserId]...';
GO
DROP INDEX [IX_UserId]
    ON [dbo].[AspNetUserClaims];
GO

PRINT N'Dropping [dbo].[AspNetUserLogins].[IX_UserId]...';
GO
DROP INDEX [IX_UserId]
    ON [dbo].[AspNetUserLogins];
GO

PRINT N'Dropping [dbo].[AspNetUserRoles].[IX_RoleId]...';
GO
DROP INDEX [IX_RoleId]
    ON [dbo].[AspNetUserRoles];
GO

PRINT N'Dropping [dbo].[AspNetUserRoles].[IX_UserId]...';
GO
DROP INDEX [IX_UserId]
    ON [dbo].[AspNetUserRoles];
GO

PRINT N'Dropping [dbo].[FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId]...';
GO
ALTER TABLE [dbo].[AspNetUserRoles] DROP CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetRoles_RoleId];
GO

PRINT N'Dropping [dbo].[FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserClaims] DROP CONSTRAINT [FK_dbo.AspNetUserClaims_dbo.AspNetUsers_UserId];
GO

PRINT N'Dropping [dbo].[FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserLogins] DROP CONSTRAINT [FK_dbo.AspNetUserLogins_dbo.AspNetUsers_UserId];
GO

PRINT N'Dropping [dbo].[FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserRoles] DROP CONSTRAINT [FK_dbo.AspNetUserRoles_dbo.AspNetUsers_UserId];
GO

PRINT N'Starting rebuilding table [dbo].[AspNetRoles]...';
GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_AspNetRoles] (
    [Id]               NVARCHAR (450) NOT NULL,
    [Name]             NVARCHAR (256) NULL,
    [NormalizedName]   NVARCHAR (256) NULL,
    [ConcurrencyStamp] NVARCHAR (MAX) NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_AspNetRoles1] PRIMARY KEY CLUSTERED ([Id] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[AspNetRoles])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_AspNetRoles] ([Id], [Name], [NormalizedName])
        SELECT   [Id],
                 [Name],
                 LOWER([Name])
        FROM     [dbo].[AspNetRoles]
        ORDER BY [Id] ASC;
    END

DROP TABLE [dbo].[AspNetRoles];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_AspNetRoles]', N'AspNetRoles';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_AspNetRoles1]', N'PK_AspNetRoles', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

PRINT N'Creating [dbo].[AspNetRoles].[RoleNameIndex]...';
GO
CREATE UNIQUE NONCLUSTERED INDEX [RoleNameIndex]
    ON [dbo].[AspNetRoles]([NormalizedName] ASC) WHERE ([NormalizedName] IS NOT NULL);
GO

PRINT N'Starting rebuilding table [dbo].[AspNetUserClaims]...';
GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_AspNetUserClaims] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [UserId]     NVARCHAR (450) NOT NULL,
    [ClaimType]  NVARCHAR (MAX) NULL,
    [ClaimValue] NVARCHAR (MAX) NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_AspNetUserClaims1] PRIMARY KEY CLUSTERED ([Id] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[AspNetUserClaims])
    BEGIN
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_AspNetUserClaims] ON;
        INSERT INTO [dbo].[tmp_ms_xx_AspNetUserClaims] ([Id], [UserId], [ClaimType], [ClaimValue])
        SELECT   [Id],
                 [UserId],
                 [ClaimType],
                 [ClaimValue]
        FROM     [dbo].[AspNetUserClaims]
        ORDER BY [Id] ASC;
        SET IDENTITY_INSERT [dbo].[tmp_ms_xx_AspNetUserClaims] OFF;
    END

DROP TABLE [dbo].[AspNetUserClaims];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_AspNetUserClaims]', N'AspNetUserClaims';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_AspNetUserClaims1]', N'PK_AspNetUserClaims', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

PRINT N'Creating [dbo].[AspNetUserClaims].[IX_AspNetUserClaims_UserId]...';
GO
CREATE NONCLUSTERED INDEX [IX_AspNetUserClaims_UserId]
    ON [dbo].[AspNetUserClaims]([UserId] ASC);
GO

PRINT N'Starting rebuilding table [dbo].[AspNetUserLogins]...';
GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_AspNetUserLogins] (
    [LoginProvider]       NVARCHAR (128) NOT NULL,
    [ProviderKey]         NVARCHAR (128) NOT NULL,
    [ProviderDisplayName] NVARCHAR (MAX) NULL,
    [UserId]              NVARCHAR (450) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_AspNetUserLogins1] PRIMARY KEY CLUSTERED ([LoginProvider] ASC, [ProviderKey] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[AspNetUserLogins])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_AspNetUserLogins] ([LoginProvider], [ProviderKey], [UserId])
        SELECT   [LoginProvider],
                 [ProviderKey],
                 [UserId]
        FROM     [dbo].[AspNetUserLogins]
        ORDER BY [LoginProvider] ASC, [ProviderKey] ASC;
    END

DROP TABLE [dbo].[AspNetUserLogins];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_AspNetUserLogins]', N'AspNetUserLogins';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_AspNetUserLogins1]', N'PK_AspNetUserLogins', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

PRINT N'Creating [dbo].[AspNetUserLogins].[IX_AspNetUserLogins_UserId]...';
GO
CREATE NONCLUSTERED INDEX [IX_AspNetUserLogins_UserId]
    ON [dbo].[AspNetUserLogins]([UserId] ASC);
GO

PRINT N'Starting rebuilding table [dbo].[AspNetUserRoles]...';
GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_AspNetUserRoles] (
    [UserId] NVARCHAR (450) NOT NULL,
    [RoleId] NVARCHAR (450) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK_AspNetUserRoles1] PRIMARY KEY CLUSTERED ([UserId] ASC, [RoleId] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[AspNetUserRoles])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_AspNetUserRoles] ([UserId], [RoleId])
        SELECT   [UserId],
                 [RoleId]
        FROM     [dbo].[AspNetUserRoles]
        ORDER BY [UserId] ASC, [RoleId] ASC;
    END

DROP TABLE [dbo].[AspNetUserRoles];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_AspNetUserRoles]', N'AspNetUserRoles';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_AspNetUserRoles1]', N'PK_AspNetUserRoles', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

PRINT N'Creating [dbo].[AspNetUserRoles].[IX_AspNetUserRoles_RoleId]...';
GO
CREATE NONCLUSTERED INDEX [IX_AspNetUserRoles_RoleId]
    ON [dbo].[AspNetUserRoles]([RoleId] ASC);
GO

PRINT N'Starting rebuilding table [dbo].[AspNetUsers]...';
GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [dbo].[tmp_ms_xx_AspNetUsers] (
    [Id]                   NVARCHAR (450)     NOT NULL,
    [UserName]             NVARCHAR (256)     NULL,
    [NormalizedUserName]   NVARCHAR (256)     NULL,
    [Email]                NVARCHAR (256)     NULL,
    [NormalizedEmail]      NVARCHAR (256)     NULL,
    [EmailConfirmed]       BIT                NOT NULL,
    [PasswordHash]         NVARCHAR (MAX)     NULL,
    [SecurityStamp]        NVARCHAR (MAX)     NULL,
    [ConcurrencyStamp]     NVARCHAR (MAX)     NULL,
    [PhoneNumber]          NVARCHAR (MAX)     NULL,
    [PhoneNumberConfirmed] BIT                NOT NULL,
    [TwoFactorEnabled]     BIT                NOT NULL,
    [LockoutEnd]           DATETIMEOFFSET (7) NULL,
    [LockoutEnabled]       BIT                NOT NULL,
    [AccessFailedCount]    INT                NOT NULL
    CONSTRAINT [tmp_ms_xx_constraint_PK_AspNetUsers1] PRIMARY KEY CLUSTERED ([Id] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [dbo].[AspNetUsers])
    BEGIN
        INSERT INTO [dbo].[tmp_ms_xx_AspNetUsers] ([Id], [Email], [NormalizedEmail], [EmailConfirmed], [PasswordHash], [SecurityStamp], [PhoneNumber], [PhoneNumberConfirmed], [TwoFactorEnabled],[LockoutEnd], [LockoutEnabled], [AccessFailedCount], [UserName], [NormalizedUserName])
        SELECT   [Id],
                 [Email],
				 LOWER([Email]),
                 [EmailConfirmed],
                 [PasswordHash],
                 [SecurityStamp],
                 [PhoneNumber],
                 [PhoneNumberConfirmed],
                 [TwoFactorEnabled],
				 [LockoutEndDateUtc],
                 [LockoutEnabled],
                 [AccessFailedCount],
                 [UserName],
				 LOWER([UserName])
        FROM     [dbo].[AspNetUsers]
        ORDER BY [Id] ASC;
    END

DROP TABLE [dbo].[AspNetUsers];

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_AspNetUsers]', N'AspNetUsers';

EXECUTE sp_rename N'[dbo].[tmp_ms_xx_constraint_PK_AspNetUsers1]', N'PK_AspNetUsers', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO

PRINT N'Creating [dbo].[AspNetUsers].[EmailIndex]...';
GO
CREATE NONCLUSTERED INDEX [EmailIndex]
    ON [dbo].[AspNetUsers]([NormalizedEmail] ASC);
GO

PRINT N'Creating [dbo].[AspNetUsers].[UserNameIndex]...';
GO
CREATE UNIQUE NONCLUSTERED INDEX [UserNameIndex]
    ON [dbo].[AspNetUsers]([NormalizedUserName] ASC) WHERE ([NormalizedUserName] IS NOT NULL);
GO

PRINT N'Creating [dbo].[AspNetRoleClaims]...';
GO
CREATE TABLE [dbo].[AspNetRoleClaims] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [RoleId]     NVARCHAR (450) NOT NULL,
    [ClaimType]  NVARCHAR (MAX) NULL,
    [ClaimValue] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY CLUSTERED ([Id] ASC)
);
GO

PRINT N'Creating [dbo].[AspNetRoleClaims].[IX_AspNetRoleClaims_RoleId]...';
GO
CREATE NONCLUSTERED INDEX [IX_AspNetRoleClaims_RoleId]
    ON [dbo].[AspNetRoleClaims]([RoleId] ASC);
GO

PRINT N'Creating [dbo].[AspNetUserTokens]...';
GO
CREATE TABLE [dbo].[AspNetUserTokens] (
    [UserId]        NVARCHAR (450) NOT NULL,
    [LoginProvider] NVARCHAR (128) NOT NULL,
    [Name]          NVARCHAR (128) NOT NULL,
    [Value]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY CLUSTERED ([UserId] ASC, [LoginProvider] ASC, [Name] ASC)
);
GO

PRINT N'Creating [dbo].[FK_AspNetUserLogins_AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserLogins] WITH NOCHECK
    ADD CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

PRINT N'Creating [dbo].[FK_AspNetUserRoles_AspNetRoles_RoleId]...';
GO
ALTER TABLE [dbo].[AspNetUserRoles] WITH NOCHECK
    ADD CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]) ON DELETE CASCADE;
GO

PRINT N'Creating [dbo].[FK_AspNetUserRoles_AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserRoles] WITH NOCHECK
    ADD CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

PRINT N'Creating [dbo].[FK_AspNetUserClaims_AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserClaims] WITH NOCHECK
    ADD CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

PRINT N'Creating [dbo].[FK_AspNetRoleClaims_AspNetRoles_RoleId]...';
GO
ALTER TABLE [dbo].[AspNetRoleClaims] WITH NOCHECK
    ADD CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [dbo].[AspNetRoles] ([Id]) ON DELETE CASCADE;
GO

PRINT N'Creating [dbo].[FK_AspNetUserTokens_AspNetUsers_UserId]...';
GO
ALTER TABLE [dbo].[AspNetUserTokens] WITH NOCHECK
    ADD CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[AspNetUsers] ([Id]) ON DELETE CASCADE;
GO

PRINT N'Checking existing data against newly created constraints';
GO
ALTER TABLE [dbo].[AspNetUserLogins] WITH CHECK CHECK CONSTRAINT [FK_AspNetUserLogins_AspNetUsers_UserId];
ALTER TABLE [dbo].[AspNetUserRoles] WITH CHECK CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId];
ALTER TABLE [dbo].[AspNetUserRoles] WITH CHECK CHECK CONSTRAINT [FK_AspNetUserRoles_AspNetUsers_UserId];
ALTER TABLE [dbo].[AspNetUserClaims] WITH CHECK CHECK CONSTRAINT [FK_AspNetUserClaims_AspNetUsers_UserId];
ALTER TABLE [dbo].[AspNetRoleClaims] WITH CHECK CHECK CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId];
ALTER TABLE [dbo].[AspNetUserTokens] WITH CHECK CHECK CONSTRAINT [FK_AspNetUserTokens_AspNetUsers_UserId];
GO

PRINT N'Update complete.';
GO