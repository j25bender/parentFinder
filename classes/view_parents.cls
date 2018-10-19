public with sharing class view_parents {
public String email {get; set;}
public String password {get; set;}
public String error {get; private set;}
public Parent__c[] parents {get; private set;}
public Child__c child {get; set;}
public String filterTime {get; set;}
public Boolean acceptPayments {get; set;}
    public view_parents() {

    }

  public void login(){
    error = null;
    child__c[] children = [select id, email__c, password__c, bedtime__c, candy__c, siblings__c, video_games__c, dedicated_room__c, hair_color__c
    from child__c where email__c = :email];
    if(children.size() == 1){
      child = children[0];
    }
    if(child != null && child.password__c.equals(password)){
      parents = parents();
      if(parents.size() == 0) {
        error = 'No Parents Found!';
      }
    } else {
      error = 'You messed up...';
    }
  }

  public void signUp() {
    acceptPayments = true;
  }

  public selectOption[] getBedTimeHours(){
    Integer currentHour = child.bedtime__c.hour();
    selectOption[] options = new selectOption[]{};
    for (Integer i = currentHour - 3; i <= currentHour + 3; i++) {
      options.add(new selectOption(String.valueOf(i), String.valueOf(i)));
    }
    return options;
  }

  public void filter(){
    child.bedtime__c = time.newInstance(Integer.valueOf(filterTime), 0, 0, 0);
    parents = parents();
  }

  private parent__c[] parents(){
		return [select id, name, bedtime__c, candy__c, siblings__c, video_games__c, dedicated_room__c
      from parent__c
      where bedtime__c >= :child.bedtime__c
      and candy__c = :child.candy__c
      and siblings__c <= :child.siblings__c
      and video_games__c = :child.video_games__c
      and dedicated_room__c = :child.dedicated_room__c
      ];
  }
}