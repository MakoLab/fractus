package com.makolab.fractus.remoteInterface
{
	 import mx.rpc.xml.Schema
	 public class BaseRemoteInterfaceServiceSchema
	{
		 public var schemas:Array = new Array();
		 public var targetNamespaces:Array = new Array();
		 public function BaseRemoteInterfaceServiceSchema():void
{		
			 var xsdXML1:XML = <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tns="http://tempuri.org/" attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="http://tempuri.org/">
    <xs:element name="GetComment">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="requestXml" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="GetCommentResponse">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="GetCommentResult" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="SetComment">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="requestXml" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="SetCommentResponse">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="SetCommentResult" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="GetChangeList">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="requestXml" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="GetChangeListResponse">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="GetChangeListResult" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="SetChange">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="requestXml" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
    <xs:element name="SetChangeResponse">
        <xs:complexType>
            <xs:sequence>
                <xs:element minOccurs="0" name="SetChangeResult" nillable="true" type="xs:string"/>
            </xs:sequence>
        </xs:complexType>
    </xs:element>
</xs:schema>
;
			 var xsdSchema1:Schema = new Schema(xsdXML1);
			schemas.push(xsdSchema1);
			targetNamespaces.push(new Namespace('','http://tempuri.org/'));
			 var xsdXML2:XML = <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tns="http://schemas.microsoft.com/2003/10/Serialization/" attributeFormDefault="qualified" elementFormDefault="qualified" targetNamespace="http://schemas.microsoft.com/2003/10/Serialization/">
    <xs:element name="anyType" nillable="true" type="xs:anyType"/>
    <xs:element name="anyURI" nillable="true" type="xs:anyURI"/>
    <xs:element name="base64Binary" nillable="true" type="xs:base64Binary"/>
    <xs:element name="boolean" nillable="true" type="xs:boolean"/>
    <xs:element name="byte" nillable="true" type="xs:byte"/>
    <xs:element name="dateTime" nillable="true" type="xs:dateTime"/>
    <xs:element name="decimal" nillable="true" type="xs:decimal"/>
    <xs:element name="double" nillable="true" type="xs:double"/>
    <xs:element name="float" nillable="true" type="xs:float"/>
    <xs:element name="int" nillable="true" type="xs:int"/>
    <xs:element name="long" nillable="true" type="xs:long"/>
    <xs:element name="QName" nillable="true" type="xs:QName"/>
    <xs:element name="short" nillable="true" type="xs:short"/>
    <xs:element name="string" nillable="true" type="xs:string"/>
    <xs:element name="unsignedByte" nillable="true" type="xs:unsignedByte"/>
    <xs:element name="unsignedInt" nillable="true" type="xs:unsignedInt"/>
    <xs:element name="unsignedLong" nillable="true" type="xs:unsignedLong"/>
    <xs:element name="unsignedShort" nillable="true" type="xs:unsignedShort"/>
    <xs:element name="char" nillable="true" type="tns:char"/>
    <xs:simpleType name="char">
        <xs:restriction base="xs:int"/>
    </xs:simpleType>
    <xs:element name="duration" nillable="true" type="tns:duration"/>
    <xs:simpleType name="duration">
        <xs:restriction base="xs:duration">
            <xs:pattern value="\-?P(\d*D)?(T(\d*H)?(\d*M)?(\d*(\.\d*)?S)?)?"/>
            <xs:minInclusive value="-P10675199DT2H48M5.4775808S"/>
            <xs:maxInclusive value="P10675199DT2H48M5.4775807S"/>
        </xs:restriction>
    </xs:simpleType>
    <xs:element name="guid" nillable="true" type="tns:guid"/>
    <xs:simpleType name="guid">
        <xs:restriction base="xs:string">
            <xs:pattern value="[\da-fA-F]{8}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{4}-[\da-fA-F]{12}"/>
        </xs:restriction>
    </xs:simpleType>
    <xs:attribute name="FactoryType" type="xs:QName"/>
    <xs:attribute name="Id" type="xs:ID"/>
    <xs:attribute name="Ref" type="xs:IDREF"/>
</xs:schema>
;
			 var xsdSchema2:Schema = new Schema(xsdXML2);
			schemas.push(xsdSchema2);
			targetNamespaces.push(new Namespace('','http://schemas.microsoft.com/2003/10/Serialization/'));
			 var xsdXML0:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://tempuri.org/Imports" xmlns:msc="http://schemas.microsoft.com/ws/2005/12/wsdl/contract" xmlns:soap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:soap12="http://schemas.xmlsoap.org/wsdl/soap12/" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:tns="http://tempuri.org/" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsa10="http://www.w3.org/2005/08/addressing" xmlns:wsam="http://www.w3.org/2007/05/addressing/metadata" xmlns:wsap="http://schemas.xmlsoap.org/ws/2004/08/addressing/policy" xmlns:wsaw="http://www.w3.org/2006/05/addressing/wsdl" xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:wsp="http://schemas.xmlsoap.org/ws/2004/09/policy" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" xmlns:wsx="http://schemas.xmlsoap.org/ws/2004/09/mex" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://tempuri.org/Imports">
    <xsd:import namespace="http://tempuri.org/" schemaLocation="http://svn_serv/RemoteInterface/RemoteInterface.svc?xsd=xsd0"/>
    <xsd:import namespace="http://schemas.microsoft.com/2003/10/Serialization/" schemaLocation="http://svn_serv/RemoteInterface/RemoteInterface.svc?xsd=xsd1"/>
</xsd:schema>
;
			 var xsdSchema0:Schema = new Schema(xsdXML0);
			schemas.push(xsdSchema0);
			targetNamespaces.push(new Namespace('','http://tempuri.org/Imports'));
			xsdSchema0.addImport(new Namespace("http://schemas.microsoft.com/2003/10/Serialization/"), xsdSchema2)
			xsdSchema0.addImport(new Namespace("http://tempuri.org/"), xsdSchema1)
		}
	}
}