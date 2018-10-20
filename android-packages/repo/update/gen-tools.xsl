<?xml version="1.0"?>

<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:addon="http://schemas.android.com/sdk/android/repo/addon2/01"
    xmlns:common="http://schemas.android.com/repository/android/common/01"
    xmlns:generic="http://schemas.android.com/repository/android/generic/01"
    xmlns:sdk="http://schemas.android.com/sdk/android/repo/repository2/01"
    xmlns:sdk-common="http://schemas.android.com/sdk/android/repo/common/01"
    xmlns:sys-img="http://schemas.android.com/sdk/android/repo/sys-img2/01"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    version="1.0">

  <xsl:output method="text" omit-xml-declaration="yes" indent="no" />
  <xsl:strip-space elements="*" />

  <xsl:template match="@obsolete">
    obsolete = <xsl:value-of select="." />;</xsl:template>

  <xsl:template match="@path">
    path = "<xsl:value-of select="." />";</xsl:template>

  <xsl:template match="revision/*[position() = 1]"><xsl:value-of select="text()" /></xsl:template>
  <xsl:template match="revision/*[position() != 1]">.<xsl:value-of select="text()" /></xsl:template>
  <xsl:template match="remotePackage/revision">
    revision = "<xsl:apply-templates select="*" />";</xsl:template>

  <xsl:template match="remotePackage/display-name">
    displayName = "<xsl:value-of select="text()" />";</xsl:template>

  <xsl:template match="remotePackage/uses-license">
    license = "<xsl:value-of select="@ref" />";</xsl:template>

  <xsl:template match="dependency/@path"> "<xsl:value-of select="." />"</xsl:template>
  <xsl:template match="remotePackage/dependencies">
    dependencies = [<xsl:apply-templates select="dependency/@path" /> ];</xsl:template>

  <xsl:template match="archive/host-os">
    <xsl:for-each select=". | ../host-bits">
      <xsl:value-of select="." />
      <xsl:if test="not(position() = last())">-</xsl:if>
    </xsl:for-each>
  </xsl:template>
  <xsl:template match="archive/complete">{
        path = "<xsl:value-of select="url" />";
        sha1 = "<xsl:value-of select="checksum" />";
      }</xsl:template>
  <xsl:template match="archive[host-os and complete]">
      "<xsl:apply-templates select="host-os" />" = <xsl:apply-templates select="complete" />;</xsl:template>
  <xsl:template match="remotePackage/archives[archive[host-os and complete]]">
    sources = {<xsl:apply-templates select="archive[host-os and complete]" />
    };</xsl:template>
  <xsl:template match="remotePackage/archives[archive[complete and not(host-os)]]">
    source = {
      path = "<xsl:value-of select="archive/complete/url" />";
      sha1 = "<xsl:value-of select="archive/complete/checksum" />";
    };</xsl:template>

  <xsl:template match="type-details[api-level]">
    apiLevel = "<xsl:value-of select="api-level" />";</xsl:template>

  <xsl:template match="libraries/library">
      {
        name = "<xsl:value-of select="@name" />";
        description = "<xsl:value-of select="description" />";
        localJarPath = "<xsl:value-of select="@localJarPath" />";
      }</xsl:template>
  <xsl:template match="type-details[@xsi:type='addon:addonDetailsType']">
    apiLevel = "<xsl:value-of select="api-level" />";
    libraries = [<xsl:apply-templates select="libraries/library" />
    ];</xsl:template>

  <xsl:template name="dependencies">[ <xsl:for-each select="dependencies/dependency/@path">"<xsl:value-of select="." />" </xsl:for-each>]</xsl:template>

  <!-- Skip unknown/unneeded elements. -->
  <xsl:template match="remotePackage/node()" />

  <xsl:template match="remotePackage">
  {<xsl:apply-templates select="@*|*" />
  }</xsl:template>



<xsl:template match="/sdk:sdk-repository|/addon:sdk-addon|/sys-img:sdk-sys-img">
# This file is generated from generate.sh. DO NOT EDIT.
# Execute generate.sh or fetch.sh to update the file.

[<xsl:apply-templates select="remotePackage" />]
</xsl:template>
</xsl:stylesheet>
