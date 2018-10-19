public class parent_finder {

	public parent__c parent { get; set; }
	public child__c child { get; set; }
	public String state { get; private set; }
	public String debug { get; private set; }

	public parent_finder() {
		state = 'start';
		debug = 'one';
	}
	public void new_parent() {
		parent = new parent__c();
		state = 'parent';
		debug = 'two';
	}
	public void new_child() {
		child = new child__c();
		state = 'child';
		debug = 'three';
	}
	public void insertFormParent() {
		insert parent;
		state = 'finished';
	}
	public void insertFormChild() {
		insert child;
		state = 'finished';
	}
	// public parent__c getparent() {
	// 	return parent;
	// }

	//check from dev console, query editor Select id from parent__c
	//
}