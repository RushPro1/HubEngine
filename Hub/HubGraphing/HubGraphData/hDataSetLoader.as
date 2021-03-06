﻿package HubGraphing.HubGraphData
{
	import flash.display.Loader;
	import flash.events.*;
	import flash.net.*;
	
	public class hDataSetLoader extends EventDispatcher
	{
		private var _DataSet:hDataSet = null;
		private var _Filename:String = null;
		
		
		public function hDataSetLoader(filename:String) 
		{
			_Filename = filename;
			
			LoadXMLFile();
		}
		
		private function LoadXMLFile():void
		{
			var myXMLURL:URLRequest = new URLRequest(_Filename);
			var myLoader:URLLoader = new URLLoader(myXMLURL);
			
			_DataSet = new hDataSet();
			myLoader.addEventListener("complete", DataLoadComplete);
		}
		
		private function DataLoadComplete(event:Event):Boolean
		{
			var XMLData:XML = new XML( event.target.data );
			
			LoadData(XMLData);
			
			_DataSet.TransformData();
			
			dispatchEvent(new hDataSetLoaderEvent(hDataSetLoaderEvent.COMPLETE, false, false, _DataSet));

			return true;
		}

		private function LoadData(dataSource:XML):Boolean
		{
			for each ( var dataType:XML in dataSource..dataType ) {
				AddDataType(dataType);
			}
			
			for each ( var dataPoint:XML in dataSource..dataPoint ) {
				AddDataPoint(dataPoint);
			}
			
			return true;
		}
		
		public function AddDataType(dataType:XML):hDataType
		{
			if (dataType["@id"] == null)
				return null;
			
			var id:String = dataType["@id"];
			
			var newDataType:hDataType = _DataSet.AddDataType(id, dataType["@type"], dataType["@type"], dataType["@binding"], dataType["@transformType"]);
			
			if (newDataType == null)
				return null;
				
			if (dataType["@minValue"] != undefined)
				newDataType.SetMinValueFixed(dataType["@minValue"]); 
			if (dataType["@maxValue"] != undefined)
				newDataType.SetMaxValueFixed(dataType["@maxValue"]); 
			
			return newDataType;
		}
		
		public function AddDataPoint(dataPoint:XML):void
		{
			if (dataPoint["@id"] == null)
				return;
			
			var id:String = dataPoint["@id"];

			_DataSet.AddDataPoint(id, dataPoint["@displayName"]);

			for each ( var dataValue:XML in dataPoint..dataValue ) {
				if (dataValue["@id"] != undefined && dataValue["@value"] != undefined)
					_DataSet.SetDataPointValue(id, dataValue["@id"], dataValue["@value"], dataValue["@displayName"]);
			}
		}
	}
	
}