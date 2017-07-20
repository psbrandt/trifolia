﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Views/Shared/Site.MVC.Master" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .ig-title > p {
            margin: 0 0 2px;
        }

        .ig-title > p:not(:first-child) {
            font-size: 75%;
            line-height: 1.25;
            position: relative;
            vertical-align: baseline;
        }

        .ig-search-table tbody tr td:first-child {
            width: 50%;
        }

        .ig-search-table tbody tr td:nth-child(2) {
            word-wrap: break-word;
            word-break: break-all;
        }

        .ig-search-table tbody tr td:nth-child(3) {
            width: 100px;
        }

    </style>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Export</h2>

    <div class="ng-cloak" ng-app="Trifolia" ng-controller="ExportCtrl">
        <form method="post" action="/api/Export">
            <div class="alert alert-info" ng-show="message">{{message}}</div>

            <div class="form-group">
                <label>Select an implementation guide</label>
                <div class="input-group">
                    <input type="hidden" name="ImplementationGuideId" ng-value="selectedImplementationGuide.Id" />
                    <input type="text" class="form-control" placeholder="No implementation guide selected" value="{{selectedImplementationGuide.DisplayName || selectedImplementationGuide.Title}}" readonly="readonly" ng-click="openSearch()" ng-required />
                    <div class="input-group-btn">
                        <button type="button" class="btn btn-primary" ng-click="openSearch()">Select</button>
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label>Select an export format</label>
                <input type="hidden" name="ExportFormat" ng-value="criteria.selectedExportFormat" />
                <select class="form-control" ng-model="criteria.selectedExportFormat" ng-options="o.id as o.name for o in getExportFormats()" ng-required>
                    <option value="">SELECT</option>
                </select>
            </div>

            <uib-tabset ng-if="criteria.selectedExportFormat != undefined && selectedImplementationGuide">
                <uib-tab heading="General">
                    <div ng-show="categorySelectionFormats.indexOf(criteria.selectedExportFormat) >= 0" ng-include="'categorySelect.html'"></div>

                    <!-- MS Word Export Options -->
                    <div ng-show="criteria.selectedExportFormat == 0">
                        <div class="form-group">
                            <label>Sort Order</label>
                            <select name="TemplateSortOrder" class="form-control">
                                <option ng-value="0">Alpha-Hierarchical</option>
                                <option ng-value="1">Alphabetically</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Document Tables</label>
                            <select name="DocumentTables" class="form-control">
                                <option ng-value="0">None</option>
                                <option ng-value="1">Both</option>
                                <option ng-value="2">List</option>
                                <option ng-value="3">Containment</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>Template/Profile Tables</label>
                            <select name="TemplateTables" class="form-control">
                                <option ng-value="0">None</option>
                                <option ng-value="1">Both</option>
                                <option ng-value="2">Context</option>
                                <option ng-value="3">Constraint Overview</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label>XML Samples</label>
                            <input type="checkbox" name="IncludeXmlSample" value="true" /> Include
                        </div>

                        <div class="form-group">
                            <label>Change List</label>
                            <input type="checkbox" name="IncludeChangeList" value="true" /> Include
                        </div>

                        <div class="form-group">
                            <label>Publish Settings</label>
                            <input type="checkbox" name="IncludeTemplateStatus" value="true" /> Include
                        </div>

                        <div class="form-group" ng-if="selectedImplementationGuide.CanEdit">
                            <label>Notes</label>
                            <input type="checkbox" id="IncludeNotes" name="IncludeNotes" value="true" /> Include
                        </div>
                    </div>

                    <div ng-show="criteria.selectedExportFormat == 7">        <!-- SCH -->
                        <div class="form-group">
                            <label>Value Set File Name</label>
                            <input type="text" class="form-control" name="VocabularyFileName" value="voc.xml">
                        </div>

                        <div class="form-group">
                            <label>Include Vocabulary</label>
                            <input type="radio" name="IncludeVocabulary" value="true"> Yes <input type="radio" name="IncludeVocabulary" value="false" checked=""> No
                        </div>

                        <div class="form-group">
                            <label>Include Custom Schematron</label>
                            <input type="radio" name="IncludeCustomSchematron" value="true" checked=""> Yes <input type="radio" name="IncludeCustomSchematron" value="false"> No
                        </div>

                        <div class="form-group">
                            <label>Default Schematron</label>
                            <input type="text" name="DefaultSchematron" value="not(.)" class="form-control">
                        </div>
                    </div>

                    <div ng-show="vocFormats.indexOf(criteria.selectedExportFormat) >= 0">
                        <div class="form-group">
                            <label>Maximum Members (0 = export all members)</label>
                            <div class="input-group">
                                <input type="number" name="MaximumMembers" class="form-control spinedit noSelect" value="0" />
                            </div>
                        </div>

                        <div class="form-group">
                            <label>Encoding</label>
                            <select class="form-control" name="Encoding">
                                <option value="0" selected>UTF-8</option>
                                <option value="1">Unicode</option>
                            </select>
                        </div>
                    </div>

                    <div ng-show="xmlFormats | contains:criteria.selectedExportFormat">
                        <div class="form-group">
                            <label>Return JSON?</label>
                            <select class="form-control" name="ReturnJSON">
                                <option ng-value="false" selected>No</option>
                                <option ng-value="true">Yes</option>
                            </select>
                        </div>
                    </div>
                </uib-tab>
                <uib-tab heading="Value Sets" ng-show="vocFormats.indexOf(criteria.selectedExportFormat) >= 0 || criteria.selectedExportFormat == 0">     <!-- MSWORD -->
                    <div ng-show="criteria.selectedExportFormat == 0">
                        <div class="form-group">
                            <label>Tables?</label>
                            <input type="radio" name="ValueSetTables" ng-value="true" ng-model="criteria.valueSetTables">Yes <input type="radio" name="ValueSetTables" ng-value="false" ng-model="criteria.valueSetTables"> No
                        </div>

                        <div class="form-group">
                            <label>Maximum Members <i class="glyphicon glyphicon-question-sign clickable" uib-tooltip="Indicates the maximum number of members that should be exported for a given value set. 0 indicates that no members should be exported, and will omit the valueset tables from the export entirely."></i></label>
                            <input type="number" class="form-control" name="MaximumValueSetMembers" ng-model="criteria.maximumMembers" ng-change="maximumMembersChanged()">
                            <span class="help-block">Changing this applies this number to all of the value sets listed in the table below.</span>
                        </div>

                        <div class="form-group">
                            <label>Create as appendix</label>
                            <input type="radio" name="ValueSetAppendix" ng-value="true" ng-model="criteria.valuesetsAsAppendix"> Yes <input type="radio" name="ValuesetAppendix" ng-value="false" ng-model="criteria.valuesetsAsApendix"> No
                        </div>
                    </div>

                    <table class="table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Identifier</th>
                                <th>Binding Date</th>
                                <th style="width: 100px;" ng-show="criteria.selectedExportFormat == 0">Max Members</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr ng-repeat="vs in valueSets">
                                <td>{{vs.Name}}</td>
                                <td>{{vs.Oid}}</td>
                                <td>{{vs.BindingDate}}</td>
                                <td>
                                    <div class="pull-right" ng-show="criteria.selectedExportFormat == 0">
                                        <input type="hidden" id="ValueSetOid" name="ValueSetOid" value="{{vs.Oid}}" />
                                        <input type="number" id="ValueSetMaxMembers" name="ValueSetMaxMembers" class="form-control" ng-model="vs.MaximumMembers" />
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td colspan="4"><b>Total Value Sets: <span>{{valueSets.length}}</span></b></td>
                            </tr>
                        </tfoot>
                    </table>
                </uib-tab>
                <uib-tab heading="Templates/Profiles" ng-show="templateSelectionFormats | contains:criteria.selectedExportFormat">
                    <div class="form-group">
                        <label>Parent Templates/Profiles</label>    
                        <div class="input-group">
                            <input type="text" class="form-control" readonly="true">
                            <span class="input-group-btn">
                                <button class="btn btn-default" type="button"><i class="glyphicon glyphicon-remove"></i></button>
                                <button class="btn btn-default" type="button" title="Select">...</button>
                            </span>
                        </div>
                    </div>

                    <div class="form-group">
                        <label>Include Inferred?</label>
                        <input type="radio" name="Inferred" ng-value="true" ng-model="criteria.includeInferred" ng-change="loadTemplates()"> Yes <input type="radio" name="Inferred" ng-value="false" ng-model="criteria.includeInferred" ng-change="loadTemplates()"> No
                    </div>

                    <table class="table">
                        <thead>
                            <tr>
                                <th><input type="checkbox" id="CheckAllTemplates" ng-checked="criteria.selectedTemplates.length == templates.length" ng-click="toggleSelectAllTemplates()" uib-tooltip="{{criteria.selectedTemplates.length == templates.length ? 'Un-select all templates' : 'Select all templates'}}" tooltip-placement="right"></th>
                                <th>Name</th>
                                <th>Identifier</th>
                                <th>This IG?</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr ng-repeat="t in templates">
                                <td><input type="checkbox" name="TemplateIds" class="templateIdCheckboxes" ng-value="t.Id" ng-checked="criteria.selectedTemplates.indexOf(t.Id) >= 0" ng-click="toggleSelectedTemplate(t.Id)"></td>
                                <td>{{t.Name}}</td>
                                <td>{{t.Oid}}</td>
                                <td>{{t.ThisIG ? 'Yes' : 'No'}}</td>
                            </tr>
                        </tbody>
                        <tfoot>
                            <tr>
                                <td colspan="4"><b>Total Templates/Profiles: <span>{{templates.length}}</span></b></td>
                            </tr>
                        </tfoot>
                    </table>
                </uib-tab>
            </uib-tabset>

            <p>
                <button type="submit" class="btn btn-default">Export</button>
            </p>
        </form>
    </div>

    <script type="text/html" id="categorySelect.html">
        <div class="form-group">
            <label>Category</label> (Hold CTRL and click to select multiple)
            <select class="form-control" multiple="multiple" name="SelectedCategories" ng-model="criteria.selectedCategories" ng-options="o for o in categories" ng-disabled="categories.length == 0">
                <option value="" ng-if="categories.length == 0">No categories available</option>
            </select>
        </div>
    </script>
    
    <script type="text/html" id="selectImplementationGuideModal.html">
        <div class="modal-header">
            <h3 class="modal-title" id="modal-title">Select an implementation guide</h3>
        </div>
        <div class="modal-body" ng-init="init()">
            <div class="alert alert-info" ng-show="message">{{message}}</div>
            
            <div class="form-group">
                <input type="text" class="form-control" ng-model="query" placeholder="Search..." ng-change="queryChanged()" ng-model-options="{ debounce: 200 }" />
            </div>

            <table class="table table-striped ig-search-table">
                <thead>
                    <tr>
                        <td>Name</td>
                        <td>Identifier</td>
                        <td>&nbsp;</td>
                    </tr>
                </thead>
                <tbody>
                    <tr ng-repeat="ig in filteredImplementationGuides">
                        <td class="ig-title">
                            <p ng-if="ig.DisplayName">{{ig.DisplayName}}</p>
                            <p ng-if="!ig.DisplayName || ig.DisplayName.toLowerCase() != ig.Title.toLowerCase()">{{ig.Title}}</p>
                            <p>{{ig.Organization}} {{ig.Status}}</p>
                        </td>
                        <td>{{ig.Identifier}}</td>
                        <td>    
                            <div class="pull-right">
                                <button type="button" class="btn btn-default" ng-click="select(ig)">Select</button>
                            </div>
                        </td>
                    </tr>
                </tbody>
                <tfoot ng-show="getFilteredImplementationGuides().length == 0">
                    <tr>
                        <td colspan="3">No templates/profiles found.</td>
                    </tr>
                </tfoot>
            </table>
        </div>
        <div class="modal-footer">
            <button class="btn btn-warning" type="button" ng-click="cancel()">Cancel</button>
        </div>
    </script>
    
    <script type="text/javascript" src="/Scripts/Export/controllers.js?<%= ViewContext.Controller.GetType().Assembly.GetName().Version %>"></script>
</asp:Content>
