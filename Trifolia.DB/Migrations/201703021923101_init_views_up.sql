/****** Object:  View [dbo].[v_impliedtemplatecount]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_impliedtemplatecount] AS 
select 
  template.impliedTemplateId AS impliedTemplateId, 
  count(*) AS total 
from template 
group by template.impliedTemplateId;

GO
/****** Object:  View [dbo].[v_containedtemplatecount]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_containedtemplatecount] AS 
select 
  template_constraint.containedTemplateId AS containedTemplateId, 
  count(*) AS total 
from template_constraint 
group by template_constraint.containedTemplateId;

GO
/****** Object:  View [dbo].[v_constraintcount]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_constraintcount] AS 
select 
  template_constraint.templateId,
  count(*) AS total 
from template_constraint 
group by template_constraint.templateId;

GO
/****** Object:  View [dbo].[v_template]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[v_template] AS
select
  t.id,
  t.oid,
  t.name,
  t.isOpen,
  ig.id as owningImplementationGuideId,
  ig.name as owningImplementationGuideTitle,
  igt.name as implementationGuideTypeName,
  tt.id as templateTypeId,
  tt.name as templateTypeName,
  ISNULL(t.primaryContext, tt.rootContext) as primaryContext,
  tt.name + ' (' + igt.name + ')' as templateTypeDisplay,
  o.name as organizationName,
  ig.publishDate,
  it.oid as impliedTemplateOid,
  it.name as impliedTemplateTitle,
  cc.total as constraintCount,
  ctc.total as containedTemplateCount,
  itc.total as impliedTemplateCount
from template t
  join implementationguidetype igt on igt.id = t.implementationGuideTypeId
  join templatetype tt on tt.id = t.templateTypeId
  left join implementationguide ig on ig.id = t.owningImplementationGuideId
  left join organization o on o.id = ig.organizationId
  left join template it on it.id = t.impliedTemplateId
  left join v_constraintCount cc on cc.templateId = t.id
  left join v_containedTemplateCount ctc on ctc.containedTemplateId = t.id
  left join v_impliedTemplateCount itc on itc.impliedTemplateId = t.id;
GO
/****** Object:  View [dbo].[v_igaudittrail]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[v_igaudittrail]
AS
SELECT
	a.username, 
	a.auditDate, 
	a.ip, 
	a.type, 
	a.note, 
	ISNULL(a.implementationGuideId, t.owningImplementationGuideId) AS implementationGuideId, 
	a.templateId, 
	a.templateConstraintId, 
	t.name AS templateName,
	tc.number AS conformanceNumber
FROM
	audit AS a 
	LEFT JOIN template AS t ON t.id = a.templateId
	LEFT JOIN template_constraint tc ON tc.id = a.templateConstraintId


GO
/****** Object:  View [dbo].[v_implementationguidefile]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_implementationguidefile]
AS
select 
  igf.id AS id,
  igf.implementationGuideId AS implementationGuideId,
  igf.fileName AS fileName,
  igf.mimeType AS mimeType,
  igf.contentType AS contentType,
  igf.expectedErrorCount AS expectedErrorCount,
  igfd.data AS data,
  igfd.updatedDate AS updatedDate,
  igfd.updatedBy AS updatedBy,
  igfd.note AS note 
from implementationguide_file igf 
  join implementationguide_filedata igfd on igfd.implementationGuideFileId = igf.id

GO
/****** Object:  View [dbo].[v_implementationGuidePermissions]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[v_implementationGuidePermissions] AS

select distinct userId, implementationGuideId, permission
from (
	select u.id as userId, igp.implementationGuideId as implementationGuideId, igp.permission as permission
	from [user] u,
	  implementationguide_permission igp
	where
	  igp.[type] = 'Everyone'

	union all

	select u.id, igp.implementationGuideId, igp.permission
	from [user] u
	  join user_group ug on ug.userId = u.id
	  join implementationguide_permission igp on igp.groupId = ug.groupId

	union all

	select u.id, igp.implementationGuideId, igp.permission
	from [user] u
	  join implementationguide_permission igp on igp.userId = u.id
) p

GO
/****** Object:  View [dbo].[v_implementationGuideTemplates]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[v_implementationGuideTemplates] AS
	WITH versionedTemplateIgs 
	AS (
		select t.id as templateId, nig.id as implementationGuideId
		from template t
			left join template nt on nt.previousVersionTemplateId	= t.id
			join implementationguide nig on nig.previousVersionImplementationGuideId = t.owningImplementationGuideId
		where nt.id is null and nig.id is not null

		union all

		select vig.templateId, nig.id
		from versionedTemplateIgs vig
		join implementationguide nig on nig.previousVersionImplementationGuideId = vig.implementationGuideId
	)

	select ig.id as implementationGuideId, t.id as templateId 
	from implementationguide ig
		join template t on t.owningImplementationGuideId = ig.id

	union all

	select ig.id, vig.templateId
	from implementationguide ig
		join versionedTemplateIgs	vig on vig.implementationGuideId = ig.id

GO
/****** Object:  View [dbo].[v_latestimplementationguidefiledata]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_latestimplementationguidefiledata]
AS
select 
  igfd.id AS id,
  igfd.implementationGuideFileId AS implementationGuideFileId,
  igfd.data AS data,
  igfd.updatedDate AS updatedDate,
  igfd.updatedBy AS updatedBy,
  igfd.note AS note
from implementationguide_file igf
  join implementationguide_filedata igfd on igfd.updatedDate = (select max(updatedDate) from implementationguide_filedata where implementationGuideFileId = igf.id)

GO
/****** Object:  View [dbo].[v_templateList]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[v_templateList]
--WITH SCHEMABINDING
AS
select 
  t1.id,
  t1.name,
  t1.oid,
  CASE 
    WHEN t1.isOpen = 1 THEN 'Yes'
	ELSE 'No' END AS [open],
  tt.name + ' (' + igt.name + ')' as templateType,
  tt.id as templateTypeId,
  CASE WHEN ig.[version] != 1 THEN ig.name + ' V' + CAST(ig.[version] AS VARCHAR(10)) ELSE ig.name END as implementationGuide,
  ig.id as implementationGuideId,
  o.name as organization,
  o.id as organizationId,
  ig.publishDate as publishDate,
  it.name as impliedTemplateName,
  it.oid as impliedTemplateOid,
  it.id as impliedTemplateId,
  t1.[description],
  t1.primaryContextType
from dbo.template t1
  join dbo.implementationguidetype igt on igt.id = t1.implementationGuideTypeId
  join dbo.templatetype tt on tt.id = t1.templateTypeId
  left join dbo.implementationguide ig on ig.id = t1.owningImplementationGuideId
  left join dbo.organization o on o.id = ig.organizationId
  left join dbo.template it on it.id = t1.impliedTemplateId


GO
/****** Object:  View [dbo].[v_templatePermissions]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE VIEW [dbo].[v_templatePermissions] AS

select distinct userId, templateId, permission
from (
	-- templates not associated with an ig are available to everyone
	select u.id as userId, t.id as templateId, 'View' as permission
	from [user] u, 
	  template t
	where t.owningImplementationGuideId is null

	union all

	select u.id, t.id, 'Edit'
	from [user] u, 
	  template t
	where t.owningImplementationGuideId is null

	union all

	-- templates associated with implementation guides
	-- the entire organization is available
	select u.id, t.id, igp.permission
	from [user] u,
	  implementationguide_permission igp
	  join template t on t.owningImplementationGuideId = igp.implementationGuideId
	where
	  igp.[type] = 'Everyone'

	union all 

	-- templates associated with implementation guides
	-- the user is part of a group given permission
	select u.id, t.id, igp.permission
	from [user] u
	  join user_group ug on ug.userId = u.id
	  join implementationguide_permission igp on igp.groupId = ug.groupId
	  join template t on t.owningImplementationGuideId = igp.implementationGuideId

	union all 

	-- templates associated with an implementation guide
	-- the user is assigned directly to the ig
	select u.id, t.id, igp.permission
	from [user] u
	  join implementationguide_permission igp on igp.userId = u.id
	  join template t on t.owningImplementationGuideId = igp.implementationGuideId
) p


GO
/****** Object:  View [dbo].[v_templateusage]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [dbo].[v_templateusage] as
select distinct 
  t.id as templateId, 
  t.name + ' (' + t.oid + ')' as templateDisplay,
  ig.id as implementationGuideId,
  ig.name + ' (' + igt.name + ')' as implementationGuideDisplay
from template t
join implementationguide ig on t.owningImplementationGuideId = ig.id
join implementationguidetype igt on igt.id = ig.implementationGuideTypeId

union all

select distinct 
  t.id as templateId, 
  t.name + ' (' + t.oid + ')' as templateDisplay,
  ig.id as implementationGuideId,
  ig.name + ' (' + igt.name + ')' as implementationGuideDisplay
from template t
join template_constraint tc on t.id = tc.containedTemplateId
join template t2 on t2.id = tc.templateId
join implementationguide ig on t2.owningImplementationGuideId = ig.id
join implementationguidetype igt on igt.id = ig.implementationGuideTypeId

union all

select distinct 
  t.id as templateId,
  t.name + ' (' + t.oid + ')' as templateDisplay,
  ig.id as implementationGuideId,
  ig.name + ' (' + igt.name + ')' as implementationGuideDisplay
from template t
join template t2 on t2.impliedTemplateId = t.id
join implementationguide ig on t2.owningImplementationGuideId = ig.id
join implementationguidetype igt on igt.id = ig.implementationGuideTypeId

GO
/****** Object:  View [dbo].[v_userSecurables]    Script Date: 2/10/2017 11:33:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE VIEW [dbo].[v_userSecurables] AS

select distinct ur.userId, [as].name 
from user_role ur
  join appsecurable_role asr on asr.roleId = ur.roleId
  join app_securable [as] on [as].id = asr.appSecurableId


GO