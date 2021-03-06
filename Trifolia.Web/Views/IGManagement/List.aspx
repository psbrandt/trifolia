﻿<%@ Page Title="Trifolia: Browse Implementation Guides" Language="C#" MasterPageFile="~/Views/Shared/Site.MVC.Master" Inherits="System.Web.Mvc.ViewPage<dynamic>" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .nameColumn {
            max-width: 350px;
        }

        th > div > select {
            width: 69% !important;
            margin-right: 5px;
        }

        .glyphicon.glyphicon-text-height,
        .glyphicon.glyphicon-sort-by-alphabet,
        .glyphicon.glyphicon-sort-by-alphabet-alt {
            cursor: pointer;
            padding-top: 8px;
        }

        tr > th:last-child {
            min-width: 181px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div id="BrowseImplementationGuides">
        <h2 data-bind="text: Title"></h2>

        <div class="input-group">
            <input id="SearchQuery" type="text" class="form-control" data-bind="value: SearchQuery, valueUpdate: 'keyup'" placeholder="Search..." />
            <div class="input-group-btn">
                <button type="button" class="btn btn-default" data-bind="click: function () { SearchQuery(''); }" title="Clear search query">
                    <i class="glyphicon glyphicon-remove"></i>
                </button>
            </div>
        </div>

        <p data-bind="if: UnauthorizedImplementationGuides().length > 0">Don't see the implementation guide you are looking for? <a href="#" data-bind="    click: OpenRequestAccess">Request access here</a>.</p>
        
        <table data-bind="with: Model" class="table table-striped">
            <thead>
                <tr>
                    <th>
                        Name
                        <i 
                            class="glyphicon" 
                            title="Sort by Name" 
                            data-bind="css: $parent.GetSortIcon('Name'), click: function () { $parent.ToggleSort('Name'); }">
                        </i>
                    </th>
                    <th style="min-width: 125px;">
                        Publish Date
                        <i 
                            class="glyphicon" 
                            title="Sort by Publish Date" 
                            data-bind="css: $parent.GetSortIcon('PublishDate'), click: function () { $parent.ToggleSort('PublishDate'); }">
                        </i>
                    </th>
                    <th>
                        <div class="input-group">
                            <select data-bind="options: $parent.Types, value: $parent.FilterType, optionsCaption: 'Type'"></select>
                            <i 
                                class="glyphicon" 
                                title="Sort by Type"
                                data-bind="css: $parent.GetSortIcon('Type'), click: function () { $parent.ToggleSort('Type'); }">
                            </i>
                        </div>
                    </th>
                    <th>
                        <div class="input-group">
                            <select data-bind="options: $parent.Statuses, value: $parent.FilterStatus, optionsCaption: 'Status', optionsText: function (item) { return item || 'NONE'; }"></select>
                            <i 
                                class="glyphicon" 
                                title="Sort by Status" 
                                data-bind="css: $parent.GetSortIcon('Status'), click: function () { $parent.ToggleSort('Status'); }">
                            </i>
                        </div>
                    </th>
                    <!-- ko if: !HideOrganization() -->
                    <th>
                        <div class="input-group">
                            <select data-bind="options: $parent.Organizations, value: $parent.FilterOrganization, optionsCaption: 'Organization', optionsText: function (item) { return item || 'NONE'; }""></select>
                            <i 
                                class="glyphicon" 
                                title="Sort by Organization" 
                                data-bind="css: $parent.GetSortIcon('Organization'), click: function () { $parent.ToggleSort('Organization'); }">
                            </i>
                        </div>
                    </th>
                    <!-- /ko -->
                    <th>
                        <div class="pull-right">
                            <!-- ko if: containerViewModel.HasSecurable(['ImplementationGuideEdit']) -->
                            <button type="button" class="btn btn-primary btn-sm" data-bind="click: $parent.Add" title="Add new implementation guide">Add</button>
                            <!-- /ko -->
                        </div>
                    </th>
                </tr>
            </thead>
            <tbody data-bind="foreach: $parent.GetItems">
                <tr>
                    <td>
                        <span data-bind="text: Title"></span>
                        <!-- ko if: DisplayName() && DisplayName() != Title() -->
                        <br />
                        <sub data-bind="text: DisplayName"></sub>
                        <!-- /ko -->
                    </td>
                    <td data-bind="text: formatDateObj(PublishDate())"></td>
                    <td data-bind="text: Type"></td>
                    <td data-bind="text: Status"></td>
                    <!-- ko if: !$parent.HideOrganization() -->
                    <td data-bind="text: Organization"></td>
                    <!-- /ko -->
                    <td>
                        <div class="btn-group btn-group-sm pull-right">
                            <button type="button" class="btn btn-default btn-sm" data-bind="click: function () { location.href = Url(); }, text: $parents[1].SelectDisplayText"></button>
                            <!-- ko if: $parents[1].ShowEdit() && containerViewModel.HasSecurable(['WebIG']) -->
                            <a class="btn btn-default btn-sm" data-bind="attr: { href: '/IG/View/' + Id() }" target="_blank">View Web</a>
                            <!-- /ko -->
                            <!-- ko if: $parents[1].ShowEdit() && containerViewModel.HasSecurable(['ImplementationGuideEdit']) -->
                            <a class="btn btn-default btn-sm" data-bind="attr: { href: '/IGManagement/Edit/' + Id() }, enable: CanEdit">Edit</a>
                            <!-- /ko -->
                        </div>
                    </td>
                </tr>
            </tbody>
        </table>
    
        <div class="modal fade" id="requestAccessDialog">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h4 class="modal-title">Request Access</h4>
                    </div>
                    <div class="modal-body" style="max-height: 350px; overflow-y: auto;">
                        <div class="form-group">
                            <label>Access Level</label>
                            <input type="radio" name="RequestEditAccess" value="false" data-bind="checked: RequestEditAccessString" /> View 
                            <input type="radio" name="RequestEditAccess" value="true" data-bind="checked: RequestEditAccessString" /> Edit
                        </div>

                        <div class="form-group">
                            <label>Message</label>
                            <textarea class="form-control" style="height: 75px;" data-bind="value: RequestAccessMessage"></textarea>
                        </div>

                        <table class="table table-striped" data-bind="foreach: UnauthorizedImplementationGuides">
                            <tr>
                                <td data-bind="text: Name"></td>
                                <td>
                                    <div class="pull-right">
                                        <button type="button" class="btn btn-primary btn-sm" data-bind="click: function () { $parent.RequestAccess(Id()); }">Request</button>
                                    </div>
                                </td>
                            </tr>
                        </table>

                        <!-- ko if: UnauthorizedImplementationGuides().length == 0 -->
                        <p>No more implementation guides available to request access to.</p>
                        <!-- /ko -->
                    </div>
                    <div class="modal-footer">
                        <!-- ko if: AccessRequestMessage -->
                        <p class="alert alert-info" data-bind="text: AccessRequestMessage"></p>
                        <!-- /ko -->

                        <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                    </div>
                </div>
                <!-- /.modal-content -->
            </div>
            <!-- /.modal-dialog -->
        </div>
    </div>

    <script type="text/javascript" src="../../Scripts/IGManagement/List.js?<%= ViewContext.Controller.GetType().Assembly.GetName().Version %>"></script>
    <script type="text/javascript">
        var viewModel;

        $(document).ready(function () {
            viewModel = new BrowseImplementationGuideViewModel('<%= Model %>');
            ko.applyBindings(viewModel, $("#BrowseImplementationGuides")[0]);

            $('#SearchQuery').keypress(function (e) {
                if (e.keyCode == 27) {
                    viewModel.SearchQuery('');
                }
            });

            $('#requestAccessDialog').modal({
                show: false,
                keyboard: false,
                backdrop: 'static'
            }).
                on('keydown', function (e) {
                    if (e.keyCode == 27) {
                        $('#requestAccessDialog').modal('hide');
                    }
                });
        });
    </script>
</asp:Content>
