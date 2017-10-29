CREATE XML SCHEMA COLLECTION [dbo].[XMLSchema_SaveProduct]
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

  <xsd:complexType name="Product">
    <xsd:complexContent>
      <xsd:restriction base="xsd:anyType">
        <xsd:sequence />
        <xsd:attribute name="ProductId" type="emptyInt" />
        <xsd:attribute name="ProductTypeId" type="xsd:int" use="required"/>
        <xsd:attribute name="ProductName" type="varchar250" use="required"/>
      </xsd:restriction>
    </xsd:complexContent>
  </xsd:complexType>

  <xsd:element name="Products">
    <xsd:complexType>
      <xsd:complexContent>
        <xsd:restriction base="xsd:anyType">
          <xsd:sequence>
            <xsd:element name="Product" type="Product" maxOccurs="unbounded" />
          </xsd:sequence>
        </xsd:restriction>
      </xsd:complexContent>
    </xsd:complexType>
  </xsd:element>
</xsd:schema>';



