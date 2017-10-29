CREATE XML SCHEMA COLLECTION [dbo].[XMLSchema_SaveStore]
AS
N'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <xsd:simpleType name="varchar250">
    <xsd:restriction base="xsd:string">
      <xsd:maxLength value="250" />
    </xsd:restriction>
  </xsd:simpleType>

  <xsd:simpleType name="emptyInt">
    <xsd:union>
      <xsd:simpleType>
        <xsd:restriction base="xsd:string">
          <xsd:length value="0"/>
        </xsd:restriction>
      </xsd:simpleType>
      <xsd:simpleType>
        <xsd:restriction base="xsd:int" />
      </xsd:simpleType>
    </xsd:union>
  </xsd:simpleType>

  <xsd:complexType name="Store">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="StoreId" type="emptyInt" />
        <xsd:attribute name="CityId" type="emptyInt" />
        <xsd:attribute name="CityName" type="varchar250" />
        <xsd:attribute name="StoreName" type="varchar250" use="required"/>
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>

  <xsd:element name="Stores">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="Store" type="Store" maxOccurs="unbounded" />
          </xsd:sequence>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>';

